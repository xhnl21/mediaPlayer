# Media Player - Local Audio Scanning & Playback Subsystem

Aplicación móvil desarrollada en **Flutter/Dart** con arquitectura limpia **Domain-Driven Design (DDD)**, gestión de estado reactiva unidireccional con **BLoC/Cubit**, estándares de seguridad ISO 27001 / OWASP MASVS y cero uso de `setState()`.

---

## 1. Módulo de Audio Local y Reproductor

Este módulo implementa el flujo integral de detección, consulta, extracción de metadatos y reproducción reactiva de archivos de audio almacenados en el dispositivo (almacenamiento interno y tarjetas SD).

### Características Principales
- **Escaneo Nativo Multiplataforma**: Integración con `on_audio_query` para interactuar con `MediaStore` en Android (respetando Scoped Storage en Android 10, 11, 12, 13 y 14+) y con `MPMediaLibrary` en iOS.
- **Motor de Reproducción Robusto**: Basado en `just_audio`, capaz de reproducir formatos MP3, WAV, AAC, FLAC y OGG tanto desde URIs de contenido (`content://...`) como rutas directas de archivo (`file://...`).
- **Reproducción Continua (Continuous Playback)**: Detección automática del estado `ProcessingState.completed` para avanzar a la siguiente pista de la lista de reproducción.
- **Manejo Seguro de Permisos en Tiempo de Ejecución**: Diagnóstico automático del estado de permisos, banners interactivos de solicitud y gestión de estados de denegación sin bloquear la interfaz.
- **Manejo Resiliente de Errores**: Detección de archivos corruptos, formatos no soportados, dispositivos vacíos y recuperación fluida mediante recarga manual (pull-to-refresh o botón de refresco).
- **Control Total desde Mini Reproductor**: Widget global con barra de progreso interactiva para salto de tiempo (*seek*), play/pause reactivo, pista previa y siguiente.

---

## 2. Permisos Requeridos y Configuración

### Android (`android/app/src/main/AndroidManifest.xml`)
Se declaran los siguientes permisos para soportar todas las versiones de Android (desde 5.0 hasta 14+):

```xml
<!-- Permiso de almacenamiento externo para Android 12 o inferior (API <= 32) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />

<!-- Permiso granular para audios en Android 13+ (API 33+) -->
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

<!-- Permiso para mantener activo el reproductor con pantalla apagada / bloqueo -->
<uses-permission android:name="android.permission.WAKE_LOCK" />

<!-- Permisos para reproducción en segundo plano -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
```

### iOS (`ios/Runner/Info.plist`)
Se incorpora la clave de descripción de uso de la biblioteca multimedia:

```xml
<key>NSAppleMusicUsageDescription</key>
<string>Media Player requires access to your music library to scan and play local audio tracks.</string>
```

---

## 3. Arquitectura del Subsistema (DDD)

```
lib/
├── domain/                               # Capa agnóstica de negocio
│   ├── entities/
│   │   └── track.dart                    # Entidad Track (AudioTrack) con album, metadatos y duraciones
│   └── repositories/
│       └── audio_player_repository.dart  # Contrato abstracto (Streams, reproducción, permisos, escaneo)
├── application/                          # Casos de uso
│   └── use_cases/player/
│       ├── audio_permission_use_cases.dart # CheckAudioPermissions, RequestAudioPermissions, ScanLocalTracks
│       └── player_use_cases.dart         # PlayTrack, PauseTrack, SeekTrack, NextTrack, PreviousTrack
├── infrastructure/                       # Implementaciones concretas
│   ├── datasources/
│   │   └── local_audio_data_source.dart  # Acceso a on_audio_query y permission_handler con manejo de scoped storage
│   └── repositories/
│       └── audio_player_repository_impl.dart # Implementación con just_audio.AudioPlayer y streams reactivos
└── presentation/                         # Interfaz reactiva
    ├── cubits/player/
    │   └── audio_player_cubit.dart       # Gestión de AudioPlayerStatus y AudioPermissionStatus
    ├── screens/
    │   └── playlist_tracks_screen.dart   # Vista de pistas, banner de permisos, estado vacío y pull-to-refresh
    └── widgets/
        └── mini_player_widget.dart       # Mini reproductor persistente con slider de seek y controles
```

---

## 4. Guía de Ejecución y Pruebas

### Pruebas Automatizadas
Para validar las reglas de arquitectura (separación estricta de capas), seguridad y tests unitarios del reproductor:

```bash
# Ejecutar suite completo de pruebas
flutter test

# Validar regla de dependencias (Dominio y Presentación nunca importan Infraestructura)
flutter test test/architecture/dependency_rule_test.dart

# Validar pruebas del repositorio y escaneo de audio local
flutter test test/infrastructure/local_audio_repository_test.dart

# Análisis estático sin advertencias
flutter analyze

# Verificación de formato Dart
dart format --set-exit-if-changed .
```

### Pruebas Manuales en Emulador o Dispositivo
1. **Concesión de Permisos**: Al abrir la pantalla de pistas del dispositivo (`AppScreen.playlistTracks`), si los permisos no están otorgados, aparecerá un banner solicitándolos. Al presionar `GRANT` o `RESCAN AUDIO`, se invoca la solicitud nativa.
2. **Escaneo de Audios**: Una vez otorgados, la aplicación lista los archivos `.mp3`, `.wav`, `.aac`, `.flac` con título, artista, álbum y duración formateada.
3. **Reproducción Inmediata**: Al tocar una pista, la barra de reproducción inicia el streaming inmediato.
4. **Controles**: Probar play, pausa, búsqueda arrastrando el slider, botón anterior y siguiente.
5. **Recarga Dinámica**: Deslizar hacia abajo (pull-to-refresh) o pulsar el icono de refresco en la esquina superior derecha para reescanear la biblioteca tras copiar nuevos archivos.