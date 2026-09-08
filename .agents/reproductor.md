Prompt para ingeniero senior Flutter/Dart – Corrección de búsqueda y reproducción de audios locales

Contexto:
Estamos desarrollando una aplicación móvil en Flutter/Dart con arquitectura DDD (Domain-Driven Design), gestión de estado reactiva con BLoC/Cubit y estrictos estándares de seguridad. Actualmente, la funcionalidad del reproductor de audio local presenta dos fallos críticos:

No se están buscando los archivos de audio en el dispositivo móvil (ni en almacenamiento interno ni en tarjetas SD).

Al obtener el listado de audios, no es posible reproducirlos (la interacción con el reproductor no funciona o no se ha implementado correctamente).

Se requiere corregir ambas funcionalidades para que el usuario pueda explorar su biblioteca de audio local y reproducir cualquier pista seleccionada.

Objetivo:
Implementar o reparar el flujo completo de escaneo de archivos de audio en el dispositivo y su posterior reproducción, respetando la arquitectura existente, las buenas prácticas de seguridad y los patrones de desarrollo establecidos.

Tareas específicas

1. Diagnóstico del estado actual
   Revisar el código existente relacionado con la búsqueda de archivos de audio (servicios, repositorios, casos de uso, cubits, UI).

Identificar por qué no se están listando los audios:

Falta de permisos de almacenamiento (READ_EXTERNAL_STORAGE, READ_MEDIA_AUDIO en Android 13+, NSAppleMusicUsageDescription en iOS).

Uso incorrecto de APIs de consulta (MediaStore, file_picker, on_audio_query, etc.).

Errores en la inyección de dependencias o en el flujo de estados del Cubit.

Posibles restricciones de scoped storage en Android 10+ que impiden acceso directo a rutas.

Documentar los hallazgos antes de implementar cambios.

2. Implementación/corrección de la búsqueda de audios
   Utilizar un paquete confiable para escanear archivos de audio (por ejemplo, on_audio_query, audio_query, o directamente MediaStore si se requiere control total).

Solicitar los permisos necesarios en tiempo de ejecución, siguiendo las guías de Android e iOS.

Asegurar que la búsqueda funcione en todas las versiones de Android soportadas (mínimo Android 5.0, con atención a Android 10+ y 13+).

Diseñar la consulta para obtener: título, artista, álbum, duración, URI del archivo, y cualquier metadato relevante.

Implementar un repositorio en la capa de infraestructura que encapsule el acceso a MediaStore y devuelva entidades de dominio (por ejemplo, AudioTrack).

Manejar errores: sin permisos, almacenamiento vacío, formatos no soportados.

3. Implementación/corrección de la reproducción de audio
   Integrar un reproductor de audio robusto (por ejemplo, just_audio, audioplayers, audio_service).

Al seleccionar un elemento del listado, se debe iniciar la reproducción inmediata o mostrar controles (play/pausa, barra de progreso, siguiente/anterior).

El estado del reproductor debe gestionarse mediante un Cubit dedicado (ej. PlayerCubit) que emita estados: loading, playing, paused, completed, error, con la posición y duración actuales.

Asegurar compatibilidad con diferentes formatos de audio (MP3, WAV, AAC, FLAC, etc.) y manejar errores de archivos corruptos o no soportados.

Implementar lógica de reproducción continua si se requiere (opcional, pero recomendado para listas).

4. Integración con la arquitectura existente
   Respetar estrictamente la separación por capas:

Domain: entidades (AudioTrack), repositorio abstracto (AudioRepository), casos de uso (GetAudioList, PlayAudio).

Application: Cubits (AudioListCubit, PlayerCubit) que orquestan los casos de uso y emiten estados.

Infrastructure: implementación del repositorio con MediaStore y del reproductor con just_audio.

Presentation: widgets que consumen los Cubits mediante BlocBuilder/BlocListener.

Prohibido el uso de setState. Todo el estado debe fluir a través de los Cubits.

La UI no debe contener lógica de negocio; solo reaccionar a los estados y enviar eventos.

5. Pruebas y validación
   Probar el flujo en emuladores y dispositivos físicos con distintas versiones de Android (y iOS si aplica).

Verificar que la lista de audios se carga correctamente y se actualiza al otorgar permisos.

Probar la reproducción de al menos 10 archivos de audio con formatos variados.

Comprobar el manejo de errores: denegación de permisos, sin archivos, archivo corrupto, interrupción por llamada telefónica, etc.

Ejecutar flutter analyze y corregir todos los warnings/errores.

Formatear el código con dart format ..

6. Documentación
   Actualizar el archivo README.md o crear uno específico si es necesario.

Documentar los permisos requeridos y los cambios en AndroidManifest.xml e Info.plist.

Explicar la arquitectura de la solución y cómo probarla.

Restricciones
No modificar la lógica de negocio existente en otras funcionalidades.

No introducir dependencias sin justificación técnica (se pueden agregar solo las necesarias para la búsqueda/reproducción).

Mantener los estándares de seguridad: no exponer rutas de archivos sensibles, usar cifrado si se almacenan metadatos localmente.

El código debe seguir las guías de estilo oficiales de Dart/Flutter y las convenciones del proyecto.

No se permite el uso de soluciones temporales o hacks; la implementación debe ser mantenible y escalable.

Criterios de aceptación
Al abrir la pantalla del reproductor, la aplicación solicita los permisos necesarios y, una vez concedidos, muestra una lista de todos los audios del dispositivo.

La lista incluye metadatos básicos (título, artista, duración) y se actualiza si se agregan o eliminan archivos (usando un botón de refrescar o automáticamente).

Al tocar un audio de la lista, comienza la reproducción y se muestran controles funcionales (play/pausa, barra de progreso).

La reproducción continúa al cambiar de orientación o al bloquear/desbloquear el dispositivo.

Se manejan correctamente los casos de error (sin permisos, sin archivos, archivo corrupto) mostrando mensajes claros al usuario.

El código cumple con las reglas de arquitectura DDD, no usa setState, y todos los estados son gestionados por Cubits.

flutter analyze no reporta issues y dart format se ha ejecutado.

Se entrega una rama fix/audio-player-local con los cambios y un breve informe de las modificaciones.

Entregable final:

Rama fix/audio-player-local fusionable.

Documentación actualizada.

Informe de pruebas realizadas y resultados.
