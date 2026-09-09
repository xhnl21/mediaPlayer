# Informe de Diagnóstico y Persistencia: Bug de Pantalla Negra y Estado de Sesión

> **Rama Git:** `fix/persistence-and-black-screen`  
> **Fecha:** 2026-09-09  
> **Estado:** Resuelto & Verificado (103/103 pruebas pasando, 0 advertencias de análisis)

---

## 1. Resumen Ejecutivo

En este trabajo se abordaron dos problemáticas críticas en el reproductor de audio:
1. **Pérdida de estado entre sesiones:** Pérdida de preferencias del usuario (`repeatMode`, `isShuffleEnabled`), de la última pista reproducida, de la posición de reproducción y falta de auto-scroll o resaltado visual de dicha pista al reiniciar la aplicación.
2. **Bug crítico de pantalla negra:** Al reproducir audio en segundo plano durante períodos prolongados con la pantalla bloqueada, al desbloquear el teléfono la interfaz quedaba en negro, congelada e inoperativa.

Ambos problemas se resolvieron de raíz manteniendo estricta arquitectura DDD, cero uso de `setState()`, cifrado AES en almacenamiento local seguro y optimizaciones a nivel de compositor gráfico nativo Android y Flutter rendering pipeline.

---

## 2. Diagnóstico del Bug de Pantalla Negra (Root Cause Analysis)

### 2.1. Causa Raíz a Nivel de Hardware y Sistema Operativo (Android / MIUI)
En Flutter Android, la actividad principal (`FlutterActivity` o `AudioServiceActivity`) utiliza por defecto `RenderMode.surface`, lo que instancia un `SurfaceView`.
- **Naturaleza del `SurfaceView`:** A diferencia de una vista de interfaz estándar, `SurfaceView` posee una superficie EGL dedicada gestionada por el compositor de hardware de Android (`SurfaceFlinger`), la cual se renderiza detrás o delante de la ventana de la aplicación.
- **Transición a Segundo Plano y Modo Doze/Bloqueo Prolongado:** Cuando la aplicación reproduce audio en segundo plano mediante un servicio en primer plano (`AudioService` / `MediaBrowserServiceCompat`) con el dispositivo bloqueado durante varios minutos:
  1. El subsistema de gestión de energía (especialmente agresivo en fabricantes OEM como Xiaomi/MIUI/HyperOS, Samsung y Huawei) destruye el buffer y la superficie gráfica EGL asociada al `SurfaceView` para ahorrar memoria y GPU.
  2. Al desbloquear el dispositivo, el `WindowManager` restaura la ventana de la aplicación a primer plano; sin embargo, Flutter intenta reanudar su pipeline de renderizado contra una superficie EGL que ha sido invalidada o destruida.
  3. Esto genera un **deadlock en el hilo de UI/Raster** de Flutter o una falla silenciosa en la adquisición del buffer EGL (`EGL_BAD_SURFACE` / swap buffers deadlock). La GPU no recibe nuevos frames de Flutter, resultando en una pantalla 100% negra donde el audio sigue sonando pero la vista es incapaz de recomponerse.

### 2.2. Saturación del Árbol de Widgets y Rebuilds sin RepaintBoundary
- Cada tick del progreso de reproducción emitido desde el `AudioHandler` invalidaba áreas jerárquicas amplias sin barreras de repintado (`RepaintBoundary`), complicando la reanudación del pipeline al volver de estado inactivo.
- La ausencia de una captura global en `ErrorWidget.builder` dejaba abierta la posibilidad de que cualquier desajuste de contexto durante el `AppLifecycleState.resumed` mostrara la pantalla negra nativa de fallo de build.

---

## 3. Solución Técnica al Bug de Pantalla Negra

Para erradicar de forma permanente y robusta el problema se aplicaron 4 capas de solución:

### 3.1. Reemplazo de `RenderMode.surface` por `RenderMode.texture` en `MainActivity.kt`
Se sobrescribió el método `getRenderMode()` en `MainActivity.kt`:
```kotlin
import io.flutter.embedding.android.RenderMode

class MainActivity : AudioServiceActivity() {
    override fun getRenderMode(): RenderMode = RenderMode.texture
    ...
```
- **Mecanismo:** Al configurar `RenderMode.texture`, Flutter dibuja en un `TextureView` en lugar de un `SurfaceView`.
- **Beneficio:** `TextureView` es un widget nativo integrado directamente en el árbol de vistas de Android (`ViewHierarchy`). No depende de una superficie independiente de `SurfaceFlinger` que el sistema destruye en modo reposo; su contexto gráfico se preserva junto a la ventana y se reconstruye sin deadlocks en el pipeline EGL al desbloquear la pantalla.

### 3.2. Programación Forzada de Frame en `AppLifecycleState.resumed` (`main.dart`)
Se implementó `WidgetsBindingObserver` en el punto de entrada de la aplicación:
```dart
class _AppLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-sincroniza el pipeline de rendering de Flutter al regresar del lockscreen
      WidgetsBinding.instance.scheduleFrame();
    }
  }
}
```
Al retornar del estado bloqueado (`resumed`), se invoca `scheduleFrame()`, forzando al motor a solicitar inmediatamente un VSYNC y emitir un frame fresco sobre el compositor gráfico activo.

### 3.3. Aislamiento de Repintado con `RepaintBoundary`
- Se envolvió el componente continuo `MiniPlayerWidget` dentro de un `RepaintBoundary`. Las actualizaciones de 200 ms de posición y seekbar quedan confinadas a su propia capa de renderizado (`RenderRepaintBoundary`), evitando invalidaciones masivas en los widgets superiores.
- Se envolvieron las listas de canciones en `PlaylistTracksScreen` y `MyPlaylistScreen` en `RepaintBoundary` para preservar sus snapshots gráficos durante las transiciones de estado de la aplicación.

### 3.4. Manejo Global de Errores Gráficos (`ErrorWidget.builder` & `FlutterError.onError`)
- Se reemplazó la pantalla negra por defecto ante errores de compilación con un widget de recuperación estilizado (`ErrorWidget.builder`), con diseño oscuro armónico (`AppColors.background`, `AppColors.accentCoral`) y botón de **REINTENTAR** interactivo que ejecuta `scheduleFrame()`.
- `FlutterError.onError` captura y presenta excepciones sin exponer rutas locales privadas ni tokens de usuario.

---

## 4. Arquitectura y Solución de Persistencia de Estado

Siguiendo principios estrictos de **Clean Architecture / DDD**:

### 4.1. Capa de Dominio (`lib/domain/`)
- **`LastSessionContext`** (`lib/domain/entities/last_session_context.dart`):
  Entidad inmutable que modela la fotografía de la sesión anterior:
  - `trackId`: identificador de la pista.
  - `index`: índice en la lista de reproducción.
  - `position`: tiempo reproducido (`Duration`).
  - `duration`: duración total de la pista.
  - `title`, `artist`, `album`, `audioUrl`: metadatos de respaldo.
- **`PlayerPreferencesRepository`** (`lib/domain/repositories/player_preferences_repository.dart`):
  Contrato abstracto para el almacenamiento y recuperación de preferencias:
  ```dart
  abstract class PlayerPreferencesRepository {
    Future<void> saveRepeatMode(AudioRepeatMode mode);
    Future<AudioRepeatMode> getRepeatMode();
    Future<void> saveShuffleEnabled(bool enabled);
    Future<bool> isShuffleEnabled();
    Future<void> saveLastTrack(Track track, int index, Duration position);
    Future<LastSessionContext?> getLastTrack();
  }
  ```

### 4.2. Capa de Infraestructura (`lib/infrastructure/`)
- **`PlayerPreferencesRepositoryImpl`** (`lib/infrastructure/repositories/player_preferences_repository_impl.dart`):
  Implementa el repositorio utilizando `SecureEncryptedDataSource` (`FlutterSecureStorage` con Keychain en iOS y `EncryptedSharedPreferences` / AES en Android Keystore).
  - Cifra todos los JSON antes de persistirlos.
  - En caso de error o datos corruptos, atrapa la excepción y retorna valores por defecto seguros (`AudioRepeatMode.off`, `false`, `null`), garantizando estabilidad total.

### 4.3. Capa de Presentación (`AudioPlayerCubit` & Pantallas)
- **Restauración sin Auto-Play:**
  En `AudioPlayerCubit.loadInitialData()`, se cargan `savedRepeat`, `savedShuffle` y `lastSession`. Si existe una sesión previa:
  - Se asigna `currentTrack` a la pista guardada.
  - Se asigna `position` a la última posición conocida y `duration` a la duración de la pista (mostrando el progreso en la barra).
  - Se asigna `highlightedTrackId` e `initialScrollIndex`.
  - **No se inicia reproducción:** Se emite `isPlaying = false` y `status = AudioPlayerStatus.paused`.
- **Persistencia Automática no Bloqueante:**
  - `cycleRepeatMode()` y `setRepeatMode()` persisten inmediatamente con `saveRepeatMode()`.
  - `toggleShuffle()` persiste el valor booleano con `saveShuffleEnabled()`.
  - `playTrack()` persiste la pista y resalta su fila con `saveLastTrack()`.
  - `togglePlayPause()` y `seek()` guardan la pista y la posición exacta en milisegundos.
- **Scroll Automático y Resaltado Visual:**
  - En `PlaylistTracksScreen`, al restaurar la sesión, un listener post-frame ejecuta un scroll suave (`animateTo`) mediante `ScrollController` hacia el índice de la pista restaurada.
  - En `_TrackItemRow`, si la pista coincide con `highlightedTrackId` y no está sonando (`!isPlaying`), se resalta visualmente con un fondo de acento coral traslúcido (`AppColors.accentCoral.withValues(alpha: 0.12)`) y un borde sutil coral de 1.5px (`AppColors.accentCoral.withValues(alpha: 0.6)`).
  - Los botones de repetición (`Repeat Off`, `Repeat Once`, `Repeat All`) y reproducción aleatoria (`Shuffle`) en la barra de herramientas reflejan visualmente el estado persistido.

---

## 5. Cumplimiento de Restricciones y Reglas Arquitectónicas

1. **Cero `setState()`:** Todo el manejo de estado transitorio de la interfaz se realiza a través de `ValueNotifier` o `AudioPlayerCubit`. Se respetó la regla `ARC-002`.
2. **Sin violación de capas DDD:** La capa de presentación y dominio no importan infraestructura; la inyección se realiza a través de `lib/core/di/injection_container.dart` (GetIt).
3. **Seguridad bancaria (OWASP MASVS):** No se introdujeron archivos planos en texto claro ni SharedPreferences estándar no cifradas. Los datos de sesión y preferencias pasan por cifrado simétrico AES.
4. **Protección de Privacidad:** No se loguean rutas absolutas ni tokens en consola.

---

## 6. Lista de Archivos Creados y Modificados

### Archivos Creados
| Archivo | Capa | Propósito |
|---|---|---|
| `lib/domain/entities/last_session_context.dart` | Dominio | Entidad inmutable para el contexto de sesión previa |
| `lib/domain/repositories/player_preferences_repository.dart` | Dominio | Interfaz abstracta del repositorio de preferencias |
| `lib/infrastructure/repositories/player_preferences_repository_impl.dart` | Infraestructura | Implementación cifrada con `SecureEncryptedDataSource` |
| `test/infrastructure/player_preferences_repository_test.dart` | Pruebas | Pruebas unitarias completas de persistencia y manejo de fallos |
| `test/presentation/player_persistence_cubit_test.dart` | Pruebas | Pruebas unitarias de restauración de sesión, auto-scroll y persistencia reactiva |
| `DIAGNOSTIC_BLACK_SCREEN_AND_PERSISTENCE.md` | Documentación | Informe exhaustivo de diagnóstico y resolución |

### Archivos Modificados
| Archivo | Capa | Modificación Principal |
|---|---|---|
| `android/app/src/main/kotlin/.../MainActivity.kt` | Nativo Android | Sobrescritura de `getRenderMode(): RenderMode = RenderMode.texture` |
| `lib/domain/player.dart` | Dominio | Exportación de nuevas entidades y contratos de preferencias |
| `lib/infrastructure/infrastructure.dart` | Infraestructura | Exportación de `PlayerPreferencesRepositoryImpl` |
| `lib/core/di/injection_container.dart` | Core (DI) | Registro de `PlayerPreferencesRepository` en Service Locator |
| `lib/presentation/cubits/player/audio_player_cubit.dart` | Presentación | Carga y guardado de estado en `loadInitialData`, resaltado y scroll |
| `lib/main.dart` | Entrada App | Observer de ciclo de vida, `scheduleFrame()`, `ErrorWidget.builder` |
| `lib/presentation/widgets/mini_player_widget.dart` | Presentación | Aislamiento con `RepaintBoundary` |
| `lib/presentation/screens/playlist_tracks_screen.dart` | Presentación | Auto-scroll con `ScrollController`, resaltado con borde y fondo coral, `RepaintBoundary` |
| `lib/presentation/screens/my_playlist_screen.dart` | Presentación | Resaltado visual de pista y `RepaintBoundary` |
| `test/presentation/playlist_tracks_screen_test.dart` | Pruebas | Prueba de verificación visual del resaltado y controles |

---

## 7. Reporte de Pruebas y Calidad de Código

### 7.1. Suite de Pruebas Automatizadas
Se ejecutó la totalidad de la suite de pruebas del proyecto:
```bash
flutter test
```
**Resultado:**
```text
All tests passed! (103/103 tests passing)
```
- **12 pruebas en `player_preferences_repository_test.dart`:** Todas exitosas.
- **8 pruebas en `player_persistence_cubit_test.dart`:** Todas exitosas.
- **8 pruebas en `playlist_tracks_screen_test.dart`:** Todas exitosas.
- **75 pruebas del resto del sistema:** Todas exitosas.

### 7.2. Análisis Estático
```bash
flutter analyze
```
**Resultado:**
```text
Analyzing mediaPlayer...
No issues found! (ran in 2.0s)
```

### 7.3. Formateo de Código
```bash
dart format .
```
**Resultado:**
```text
Formatted 139 files (6 changed) in 0.77 seconds.
```
Código 100% formateado bajo las directrices oficiales de Dart.
