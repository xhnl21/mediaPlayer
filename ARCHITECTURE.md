# Arquitectura y Especificación de Seguridad: Media Player Mobile

Este documento detalla las decisiones arquitectónicas, principios de diseño, mecanismos de seguridad de grado bancario y patrones de gestión de estado implementados en la aplicación móvil **Media Player**, desarrollada en Flutter y Dart en estricto cumplimiento de las directrices de [.agents/app.md](file:///Users/programacion/Documents/mediaPlayer/.agents/app.md).

---

## 1. Arquitectura Domain-Driven Design (DDD)

El proyecto sigue una arquitectura limpia estructurada en cuatro capas concéntricas con regla de dependencia estricta dirigida hacia el dominio:

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│   (Screens "tontas", Widgets modulares, Cubits, States)│
└───────────────────────────┬────────────────────────────┘
                            │ usa
┌───────────────────────────▼────────────────────────────┐
│                    Application Layer                   │
│                (Casos de Uso, Orquestación)            │
└───────────────────────────┬────────────────────────────┘
                            │ invoca
┌───────────────────────────▼────────────────────────────┐
│                      Domain Layer                      │
│   (Entidades, Value Objects, Repositorios Abstractos)  │
└───────────────────────────▲────────────────────────────┘
                            │ implementa
┌───────────────────────────┴────────────────────────────┐
│                 Infrastructure Layer                   │
│  (Repositorios Impl, Data Sources, Cifrado AES-256)    │
└────────────────────────────────────────────────────────┘
```

### Capas y Responsabilidades

1. **Domain (`lib/domain/`)**:
   - El núcleo agnóstico del sistema sin dependencias externas.
   - **Value Objects**: Encapsulan reglas invariantes y validaciones en el momento de instanciación (`EmailAddress`, `Password`, `AudioFrequency`, `EqualizerGain`).
   - **Entities**: Objetos de negocio con identidad única (`UserProfile`, `Track`, `Playlist`, `RadioStation`, `EqualizerSetting`, `VoiceRecording`, `AudioSettings`).
   - **Repositories**: Contratos e interfaces abstractas (`AuthRepository`, `AudioPlayerRepository`, `EqualizerRepository`, `RadioRepository`, `VoiceRecorderRepository`, `SettingsRepository`, `SecurityAuditRepository`).

2. **Application (`lib/application/`)**:
   - Contiene los casos de uso específicos de la aplicación (`LoginUseCase`, `RegisterUseCase`, `PlayTrackUseCase`, `UpdateEqualizerBandUseCase`, `TuneRadioFrequencyUseCase`, etc.).
   - Orquesta la ejecución de lógica de negocio y audita eventos sensibles hacia la capa de seguridad.

3. **Infrastructure (`lib/infrastructure/`)**:
   - Implementaciones concretas de repositorios (`AuthRepositoryImpl`, `AudioPlayerRepositoryImpl`, `EqualizerRepositoryImpl`, `RadioRepositoryImpl`, etc.).
   - Persistencia segura con cifrado AES-256 (`SecureEncryptedDataSource`).
   - Mock Data Source (`MusicMockDataSource`) con datos de playlists, tracks, géneros y frecuencias de radio fieles al diseño.

4. **Presentation (`lib/presentation/`)**:
   - Capa de interfaz de usuario completamente declarativa y reactiva.
   - **Cero uso de `setState()`**: La totalidad de la reactividad se maneja con `flutter_bloc` (`Cubit` y `State` inmutables basados en `Equatable`).
   - Widgets modulares y agnósticos de la lógica de negocio.

---

## 2. Seguridad de Grado Bancario y Cumplimiento Normativo (ISO 27001 / OWASP MASVS)

### Cifrado de Datos en Reposo (AES-256-CBC)
- Implementado en `AesEncryptionService` utilizando el paquete `encrypt` y `pointycastle`.
- Cada operación de cifrado genera un vector de inicialización (IV) criptográficamente seguro de 128 bits (`enc.IV.fromSecureRandom(16)`).
- El IV se prepende a los bytes del texto cifrado y se emite en Base64, impidiendo ataques de repetición o análisis de frecuencias.

### Almacenamiento Seguro de Claves
- Implementado en `SecureStorageService` mediante `flutter_secure_storage`.
- **iOS**: Almacenamiento en Keychain protegido con `KeychainAccessibility.first_unlock`.
- **Android**: `EncryptedSharedPreferences` respaldado por el Android Keystore con cifrado de clave maestra por hardware (TEE/StrongBox).

### Pista de Auditoría de Seguridad Cifrada (OWASP MASVS / ISO 27001)
- `AuditLogger` y `SecurityAuditRepositoryImpl` registran eventos críticos del sistema (`AUTH_LOGIN_SUCCESS`, `AUTH_LOGIN_FAILURE`, `SETTINGS_UPDATED`, etc.) con marca de tiempo UTC y nivel de severidad.
- Cada registro de auditoría se cifra individualmente con AES-256 antes de almacenarse localmente.

### Prevención de Inyecciones y Sanitización de Entradas
- `InputSanitizer` elimina caracteres de control ASCII (0-31), tags HTML y secuencias de script en formularios de autenticación y búsquedas.
- Los Value Objects (`EmailAddress`, `Password`) garantizan tipado estricto e inmutabilidad antes de que los datos ingresen a casos de uso o repositorios.

---

## 3. Gestión de Estado y Flujo Unidireccional (BLoC / Cubit)

Para garantizar la estabilidad y cumplir la regla de **prohibición total de `setState()`**:

| Cubit | Estado Inmutable | Responsabilidad |
|---|---|---|
| `NavigationCubit` | `NavigationState` | Control del shell principal, índice de la barra inferior y transición entre las 12 pantallas. |
| `AuthCubit` | `AuthState` (`AuthInitial`, `AuthLoading`, `Authenticated`, `Unauthenticated`, `AuthError`) | Estado de sesión, login y registro. |
| `AuthFormCubit` | `AuthFormState` | Estado reactivo local del formulario (tabs, campos, checkbox de términos). |
| `AudioPlayerCubit` | `AudioPlayerState` | Posición del audio, duración, estado de reproducción (play/pause/next/prev) y favoritos. |
| `LibraryCubit` | `LibraryState` | Filtrado por género (Pop, Rock, Jazz, Hip Hop), búsqueda segura y pestañas. |
| `EqualizerCubit` | `EqualizerState` | Ganancia de 6 bandas de frecuencia, potenciómetros (Bass, Treble, Vocal) y guardado cifrado. |
| `RadioCubit` | `RadioState` | Sintonización continua de frecuencia FM, reproducción de emisoras y volumen. |
| `RecorderCubit` | `RecorderState` | Grabación de voz, cronómetro, fluctuación reactiva de amplitud y guardado de notas. |
| `SettingsCubit` | `SettingsState` | 4 interruptores de ecualización y procesamiento de audio "Lorem Color". |

---

## 4. Réplica Fiel de las 12 Pantallas del Prototipo

El sistema de diseño visual utiliza la paleta de colores y componentes extraídos de las imágenes de referencia:

- **Colores Principales**:
  - `primaryTeal` (`#339384`) / `cardSurface` (`#4BAEA0`) / `inputBackground` (`#5AB6A9`).
  - `accentCoral` (`#DC6C63`): Botones de acción clave (`GET STARTED`, `LOG IN`, `CREATE`, `LOREM`, sliders, selector de frecuencia).
  - `textLight` (`#FFFFFF`), `textSecondary` (`#BCEAE3`).

- **Catálogo de Pantallas**:
  1. `WelcomeScreen` (Screen 1): Logotipo icónico de reproducción, bienvenida y botón `GET STARTED`.
  2. `AuthScreen` (Screen 2): Pestañas `LOG IN` / `SIGN UP`, 5 campos con bordes suaves, botón coral y checkbox.
  3. `ProfileScreen` (Screen 3): Avatar circular, datos del usuario, lista de 5 opciones de menú y `Log out`.
  4. `DashboardGridScreen` (Screen 4): Cuadrícula 2x4 con 8 tarjetas redondeadas de categorías.
  5. `PlaylistTracksScreen` (Screen 5): Lista de canciones con checkboxes, corazones, carritos y `MiniPlayerWidget` integrado.
  6. `MyPlaylistScreen` (Screen 6): Encabezado con insignia de estrella coral, botones `LISTEN` y `PLUS`, pestañas y pistas.
  7. `SearchGenresScreen` (Screen 7): Barra `Search...` y tarjetas horizontales para Pop, Rock, Jazz y Hip Hop.
  8. `AlbumDetailScreen` (Screen 8): Tarjeta superior de álbum, barra de acento coral, calificación de 5 estrellas y botón `LOREM`.
  9. `RadioFmScreen` (Screen 9): Curva de espectro interactiva (`InteractiveWaveformTuner`), transporte y slider de volumen.
  10. `EqualizerScreen` (Screen 10): 6 faders verticales (`VerticalFaderSlider`), presets y 3 perillas giratorias (`RotaryKnobWidget`).
  11. `VoiceRecorderScreen` (Screen 11): Micrófono central concéntrico reactivo (`CircularMicIndicator`), controles de grabación y notas.
  12. `SoundSettingsScreen` (Screen 12): Pantalla `LOREM COLOR` con 4 switches y botón coral `CREATE`.

---

## 5. Control de Calidad y Pruebas

- **Análisis Estático**:
  - `flutter analyze` ejecutado con reglas estrictas (`analysis_options.yaml`). **0 errores, 0 warnings, 0 lints**.
- **Formato**:
  - `dart format .` aplicado a todo el árbol de archivos.
- **Auditoría de `setState`**:
  - Búsqueda recursiva con ripgrep confirma **cero llamadas a `setState`** en `lib/`.
- **Suite de Pruebas**:
  - Pruebas de reglas de dependencia y arquitectura limpia (`test/architecture/dependency_rule_test.dart`).
  - Pruebas unitarias de Value Objects (`test/domain/value_objects_test.dart`).
  - Pruebas del subsistema de cifrado y auditoría (`test/security/aes_encryption_test.dart`).
  - Pruebas de Cubits (`test/presentation/cubits_test.dart`).
  - Pruebas de widgets y navegación (`test/presentation/widget_render_test.dart`).
  - **18/18 pruebas pasando exitosamente**.

---

## 6. Arquitectura de Barriles Contextuales y Límites de Dependencia (Barrel Architecture)

En estricto cumplimiento de [.agents/barriles.md](file:///Users/programacion/Documents/mediaPlayer/.agents/barriles.md), se ha estandarizado el uso de archivos barril organizados por Bounded Contexts y se ha blindado el aislamiento de la capa de Infraestructura.

### Principios Rectores

1. **Aislamiento Total de Infraestructura**:
   - `lib/infrastructure/infrastructure.dart` exporta únicamente las clases necesarias para el Composition Root del contenedor de inyección de dependencias (`lib/core/di/injection_container.dart`).
   - Las capas de `Presentation`, `Domain` y `Application` tienen **prohibido de forma absoluta importar cualquier archivo de `lib/infrastructure/`**.
   - Cualquier pantalla, widget o cubit que requiera interactuar con el sistema debe consumir casos de uso (`lib/application/...`) o interfaces/contratos de dominio (`lib/domain/...`), nunca repositorios concretos o data sources.

2. **Barriles por Bounded Context en Dominio (`lib/domain/`)**:
   - `auth.dart`: Entidades (`UserProfile`), Value Objects (`EmailAddress`, `Password`) y contrato `AuthRepository`.
   - `player.dart`: Entidades (`Track`, `Playlist`) y contrato `AudioPlayerRepository`.
   - `equalizer.dart`: Entidades (`EqualizerSetting`), Value Objects (`AudioFrequency`, `EqualizerGain`) y contrato `EqualizerRepository`.
   - `radio.dart`: Entidades (`RadioStation`) y contrato `RadioRepository`.
   - `recorder.dart`: Entidades (`VoiceRecording`) y contrato `VoiceRecorderRepository`.
   - `settings.dart`: Entidades (`AudioSettings`) y contrato `SettingsRepository`.
   - `security.dart`: Entidades de auditoría y contrato `SecurityAuditRepository`.
   - `domain.dart`: Barril raíz unificado que re-exporta los contextos de dominio para imports consolidados.

3. **Barriles por Bounded Context en Aplicación (`lib/application/`)**:
   - `auth.dart`: Casos de uso `LoginUseCase` y `RegisterUseCase`.
   - `player.dart`: Casos de uso `PlayTrackUseCase`, `TogglePlayPauseUseCase`, `ToggleFavoriteUseCase`.
   - `equalizer.dart`: Casos de uso `UpdateEqualizerBandUseCase`, `SaveEqualizerPresetUseCase`.
   - `radio.dart`: Casos de uso `TuneRadioFrequencyUseCase`, `ToggleRadioPlaybackUseCase`.
   - `recorder.dart`: Casos de uso `StartVoiceRecordingUseCase`, `StopVoiceRecordingUseCase`.
   - `settings.dart`: Casos de uso `UpdateSoundSettingsUseCase`.
   - `application.dart`: Barril raíz unificado que re-exporta los casos de uso por contexto.

4. **Barriles Modulares de Presentación (`lib/presentation/`)**:
   - `cubits.dart`: Exporta los 8 Cubits y sus estados inmutables (`NavigationCubit`, `AuthCubit`, `AuthFormCubit`, `AudioPlayerCubit`, `LibraryCubit`, `EqualizerCubit`, `RadioCubit`, `RecorderCubit`, `SettingsCubit`).
   - `screens.dart`: Exporta las 12 pantallas UI declarativas del catálogo.
   - `widgets.dart`: Exporta los componentes de interfaz reutilizables (`InteractiveWaveformTuner`, `VerticalFaderSlider`, `RotaryKnobWidget`, `CircularMicIndicator`, `MiniPlayerWidget`, etc.).
   - `presentation.dart`: Barril raíz unificado de la capa de presentación.

5. **Barril Central del Core (`lib/core/`)**:
   - `core.dart`: Exporta constantes temáticas (`AppColors`, `AppTypography`), utilitarios de sanitización (`InputSanitizer`) y el Composition Root (`setupInjectionContainer`, `sl`).

6. **Garantía y Verificación Automatizada de Arquitectura**:
   - Se ha implementado el test automatizado `test/architecture/dependency_rule_test.dart` que analiza estáticamente los imports del proyecto en tiempo de CI/CD:
     - Valida recursivamente que ningún archivo en `lib/presentation/`, `lib/domain/` o `lib/application/` contenga imports de `infrastructure`.
     - Valida que `lib/infrastructure/infrastructure.dart` solo sea importado de forma exclusiva por `lib/core/di/injection_container.dart`.

---

## 7. Enrutamiento Declarativo y Deep Linking Centralizado (GoRouter)

En estricto cumplimiento de [.agents/goRoute.md](file:///Users/programacion/Documents/mediaPlayer/.agents/goRoute.md), se ha migrado el sistema de navegación a una arquitectura declarativa, segura y centralizada con `go_router`:

### Principios y Componentes

1. **Constantes Centralizadas de Rutas (`lib/presentation/router/route_names.dart`)**:
   - Centraliza todas las rutas como constantes inmutables (`welcome`, `auth`, `dashboard`, `search`, `tracks`, `myPlaylist`, `album`, `radio`, `equalizer`, `recorder`, `settings`, `profile`).
   - Evita "magic strings" y desacopla la definición de la URL de las pantallas consumidoras.

2. **Configuración de Enrutador (`lib/presentation/router/app_router.dart`)**:
   - `AppRouter.createRouter(authCubit)`: Fabrica la instancia singleton de `GoRouter` vinculada reactivamente a los cambios de estado de `AuthCubit` mediante `GoRouterRefreshStream`.
   - **Auth Guards (`redirect`)**:
     - Usuarios no autenticados que intentan acceder a rutas protegidas (`/dashboard`, `/equalizer`, `/radio`, etc.) son redirigidos automáticamente a `/welcome`.
     - Usuarios autenticados que intentan acceder a rutas públicas de autenticación (`/welcome`, `/auth`) son redirigidos automáticamente a `/dashboard`.
   - **Rutas Anidadas con `ShellRoute`**:
     - Las rutas de contenido protegido se renderizan dentro de `ShellRoute` alojando a `MainShellScreen`.
     - Proporciona persistencia de la barra de navegación inferior (`CustomBottomNavBar`), barra superior adaptativa y espacio para el mini reproductor.
   - **Manejo de Errores 404 (`_NotFoundScreen`)**:
     - Intercepta cualquier URL desconocida o deep link no registrado mostrando una interfaz estilizada con botón para retornar a la ruta de inicio.

3. **Compatibilidad Bidireccional con BLoC (`NavigationCubit`)**:
   - Los eventos de cambio de pantalla en `NavigationCubit` despachan comandos declarativos `AppRouter.router.go(routePath)`.
   - A su vez, `MainShellScreen` calcula el índice de la barra inferior reactivamente a partir de `GoRouterState.of(context).matchedLocation`, garantizando sincronía perfecta entre URL y UI.

4. **Soporte de Deep Linking**:
   - **Android**: `AndroidManifest.xml` configurado con filtro de intención `<intent-filter>` para el esquema `mediaplayer://app`.
   - **iOS**: `Info.plist` configurado con `CFBundleURLTypes` y esquema `mediaplayer`.
   - Permite invocar pantallas directamente desde enlaces externos (por ejemplo: `mediaplayer://app/equalizer`).

---

## 8. Persistencia Local Drift (SQLite), Claves Primarias UUID v4 y Mejoras de Reproducción

En estricto cumplimiento de [.agents/newFunctionPlayerMedia.md](file:///Users/programacion/Documents/mediaPlayer/.agents/newFunctionPlayerMedia.md) y de los requerimientos de persistencia relacional local con Drift y SQLite:

### 1. Base de Datos Relacional Local con Drift y SQLite
- Implementado utilizando `drift: ^2.16.0`, `sqlite3: ^3.5.2` y `uuid: ^4.6.0`.
- **Claves Primarias Mandatorias UUID v4**: Todas las tablas de la base de datos local (incluyendo `FavoritesTable`) definen `TextColumn get id => text()();` como clave primaria mandatoria (`primaryKey => {id}`). La generación y validación de IDs utiliza exclusivamente la especificación UUID versión 4 RFC 4122.
- **Data Source y Repositorio**: `DriftFavoritesDataSourceImpl` y `FavoritesRepositoryImpl` encapsulan las operaciones de inserción, consulta ordenada por fecha, eliminación por ID y suscripción reactiva a cambios mediante `watchAllFavorites()`.
- **In-Memory Testing**: Para pruebas automatizadas de integración y repositorios, `AppDatabase` soporta constructores con `NativeDatabase.memory()`, permitiendo ejecución de tests instantánea y sin efectos secundarios en el sistema de archivos físico.

### 2. Modos de Repetición (`AudioRepeatMode`)
- Modos disponibles: `off` (sin repetición), `once` (repite la pista actual una vez al finalizar), y `all` (bucle continuo de la playlist).
- Para evitar colisiones de nombres con el `RepeatMode` del framework Material de Flutter (`package:flutter/material.dart`), el enum del dominio se nombra `AudioRepeatMode` con alias tipado `typedef RepeatMode = AudioRepeatMode;`.
- Gestionado reactivamente por `AudioPlayerCubit` e integrado con listeners de finalización de pista en `AudioPlayerRepositoryImpl`.

### 3. Reproducción Aleatoria (Shuffle)
- Botón de alternancia de reproducción aleatoria accesible desde la barra de herramientas de la lista de pistas.
- Cuando está activo, la lista de pistas mantiene un orden pseudoaleatorio barajado sin repetición de temas hasta agotar la cola.

### 4. Eliminación de Pistas y Confirmación Modal
- **Eliminación individual**: Cada pista cuenta con un icono de borrado que despliega un diálogo de confirmación `AlertDialog` informando al usuario que la acción solo remueve la pista de la lista de reproducción en memoria y no elimina archivos físicos del almacenamiento del dispositivo.
- **Selección múltiple**: Modo de selección por checkboxes con barra de acciones que indica la cantidad de pistas seleccionadas y botón de eliminación en bloque ("REMOVE ALL (N)").

### 5. Supresión Definitiva de Iconos de Carrito de Compra
- Se ha eliminado cualquier icono, botón, tooltip o texto alusivo a "carrito de compra" en las vistas de pistas, asegurando que la interfaz esté 100% enfocada en reproducción de audio y gestión de favoritos.


