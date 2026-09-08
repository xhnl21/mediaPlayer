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

