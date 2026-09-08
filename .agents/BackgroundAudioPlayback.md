Prompt para ingeniero senior Flutter/Dart – Reproducción de audio en segundo plano con pantalla bloqueada

Contexto:
La aplicación es un reproductor de audio local desarrollado en Flutter/Dart, que sigue una arquitectura DDD estricta, gestión de estado reactiva con BLoC/Cubit y altos estándares de seguridad. Actualmente, la reproducción se detiene o se interrumpe cuando el usuario bloquea la pantalla del dispositivo o la aplicación pasa a segundo plano. Se requiere implementar la capacidad de reproducir audio de forma continua e ininterrumpida incluso con el teléfono bloqueado, mostrando controles básicos en la pantalla de bloqueo y en la notificación, cumpliendo con las guías de Android e iOS y sin comprometer la arquitectura existente.

Objetivo:
Habilitar la reproducción en segundo plano (background playback) para el reproductor de audio local, permitiendo que el audio continúe sonando al bloquear el dispositivo, y que el usuario pueda controlar la reproducción (play/pausa, siguiente/anterior, barra de progreso) desde la pantalla de bloqueo, el centro de control o la notificación persistente, según la plataforma.

Requisitos funcionales
Reproducción continua en segundo plano

El audio debe seguir reproduciéndose al bloquear la pantalla, al cambiar de aplicación o al presionar el botón Home.

La reproducción no debe interrumpirse salvo por eventos del sistema (llamadas, alarmas, desconexión de auriculares, etc.) y debe reanudarse o pausarse según la lógica definida.

Controles en pantalla de bloqueo y notificación

Mostrar metadatos del audio (título, artista, álbum, carátula si está disponible).

Botones funcionales: reproducir/pausar, pista anterior, pista siguiente, y opcionalmente barra de progreso con seek.

En Android: notificación persistente con acciones, compatible con versiones 8.0+ (canales de notificación).

En iOS: integración con MPNowPlayingInfoCenter y MPRemoteCommandCenter para control desde la pantalla de bloqueo y el centro de control.

Manejo de interrupciones

Pausar automáticamente ante llamadas telefónicas o alarmas.

Reanudar la reproducción cuando finalice la interrupción (opcional, configurable).

Manejar la desconexión de auriculares Bluetooth o con cable (pausar o continuar según preferencia).

Responder a eventos de audio focus (Android) y AVAudioSession (iOS) de forma correcta.

Integración con la arquitectura existente

La lógica de reproducción actual está en AudioPlayerCubit (Cubit de la capa de aplicación). Se debe extender o adaptar para que sea compatible con el servicio de background.

Mantener la separación de capas: el servicio de audio en segundo plano (por ejemplo, audio_service) debe ser una dependencia de infraestructura, no de dominio.

El estado de reproducción debe seguir gestionándose desde el Cubit, y el servicio debe reflejar y controlar ese estado.

Persistencia de la sesión

Si la aplicación es cerrada por el usuario (swipe), la reproducción puede detenerse o continuar dependiendo de la configuración (se recomienda detener para evitar consumo inesperado, salvo que se implemente un servicio en primer plano con notificación persistente).

En Android, usar un Foreground Service con notificación obligatoria para mantener la reproducción en segundo plano sin ser matada por el sistema.

Eficiencia energética y rendimiento

Minimizar el consumo de batería: liberar recursos cuando no se reproduce, usar AudioSession adecuado.

Evitar mantener la pantalla activa innecesariamente.

Tareas de implementación
Selección e integración de dependencias

Evaluar e integrar un paquete robusto para manejo de audio en segundo plano, preferiblemente audio_service (que funciona en Android e iOS) combinado con just_audio (o el reproductor actual).

Añadir las dependencias necesarias al pubspec.yaml con versiones estables.

Configuración de plataforma

Android:

Crear un servicio en primer plano (AudioService) con tipo mediaPlayback.

Declarar el servicio y los permisos en AndroidManifest.xml (FOREGROUND_SERVICE, WAKE_LOCK, READ_MEDIA_AUDIO, etc.).

Crear canales de notificación para versiones Android 8.0+.

Configurar audio_service para manejar MediaSessionCompat.

iOS:

Habilitar background modes en Info.plist: audio.

Configurar AVAudioSession para categoría playback y activar sesión.

Implementar MPNowPlayingInfoCenter y MPRemoteCommandCenter (puede ser gestionado por audio_service automáticamente).

Adaptar el AudioPlayerCubit y el reproductor

Crear una abstracción de reproductor que sea capaz de funcionar en background (por ejemplo, un wrapper que use AudioHandler de audio_service).

El AudioPlayerCubit debe comunicarse con el AudioHandler mediante streams/eventos, sin acoplar la lógica de negocio al servicio.

Sincronizar el estado del reproductor (posición, duración, pista actual) entre el Cubit y el servicio.

Implementar controles remotos

Configurar AudioHandler para exponer acciones: play, pause, skipToNext, skipToPrevious, seek.

En la UI de la aplicación, los controles deben seguir funcionando y reflejar los cambios provenientes de los controles externos (lock screen).

Asegurar que al bloquear el teléfono, la notificación muestre los botones correctos y el estado actual.

Manejo de ciclo de vida de la app

Implementar lógica para iniciar/detener el servicio según la reproducción.

Si la app se cierra completamente, decidir si se detiene el servicio o se mantiene (según requisitos). Se recomienda detenerlo y limpiar recursos.

Pruebas exhaustivas

Probar en dispositivos físicos Android (varias versiones) y iOS (si disponible).

Validar escenarios: bloquear pantalla, pausar desde lock screen, cambiar pista, interrupciones por llamada, desconexión de auriculares, rotación del dispositivo.

Verificar que la notificación se actualiza correctamente (metadatos, botones).

Comprobar que no hay fugas de memoria ni consumo excesivo de batería.

Documentación

Explicar la arquitectura del servicio de background y su integración con DDD/BLoC.

Incluir instrucciones para probar y configurar en nuevas instalaciones.

Restricciones y reglas
No modificar la lógica de negocio existente en otras funcionalidades.

Prohibido el uso de setState; todo el estado debe fluir a través de los Cubits.

Mantener la separación estricta por capas: el servicio de audio es infraestructura, no dominio.

No introducir dependencias innecesarias; justificar cada una.

La seguridad sigue siendo prioridad: no exponer metadatos sensibles en la notificación, usar permisos mínimos.

El código debe compilar sin errores y superar flutter analyze sin warnings.

Se debe ejecutar dart format . antes de la entrega.

Criterios de aceptación
Reproducción continua: al bloquear el teléfono, el audio sigue sonando sin interrupciones.

Controles en pantalla de bloqueo: se muestran correctamente los metadatos y los botones de play/pausa, anterior y siguiente funcionan.

Notificación persistente (Android): aparece mientras se reproduce, con acciones funcionales.

Interrupciones: una llamada entrante pausa la reproducción y, al finalizar, se reanuda (según configuración).

Sincronización de estado: cualquier cambio desde los controles externos se refleja en la UI de la app y viceversa.

Arquitectura: no hay setState, la lógica está en Cubits, y el servicio de background está aislado en infraestructura.

Rendimiento: el consumo de batería es razonable, sin wakelocks innecesarios cuando no se reproduce.

Calidad: flutter analyze sin issues, dart format aplicado, y pruebas manuales documentadas.

Documentación: se entrega un informe con los cambios y guía de configuración.

Entregables:

Rama feature/background-audio con todos los cambios.

Archivos de configuración actualizados (AndroidManifest.xml, Info.plist, etc.).

Documentación técnica en BACKGROUND_AUDIO.md.

Reporte de pruebas realizadas y resultados.
