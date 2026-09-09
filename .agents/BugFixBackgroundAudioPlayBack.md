Prompt para ingeniero senior Flutter/Dart – Corrección de persistencia de estado y bug de pantalla negra en reproducción en segundo plano

Contexto:
La aplicación es un reproductor de audio local desarrollado en Flutter/Dart, que sigue una arquitectura DDD estricta, gestión de estado reactiva con BLoC/Cubit y altos estándares de calidad. Se han identificado dos problemas críticos que afectan la experiencia del usuario y la estabilidad de la aplicación:

Problema 1: Falta de persistencia de estado entre sesiones
Al cerrar completamente la aplicación (swipe o force stop), se pierden las preferencias de reproducción y el contexto de la sesión anterior:

El modo de repetición (RepeatMode.off, RepeatMode.once, RepeatMode.all) se reinicia a off.

La reproducción aleatoria (isShuffleEnabled) se desactiva.

No se conserva la última pista seleccionada ni su posición en la lista.

Al reabrir la app, no se hace scroll automático ni se resalta visualmente la última pista reproducida.

Problema 2: Pantalla negra tras reproducción en segundo plano
Cuando la aplicación está reproduciendo audio en segundo plano (con el teléfono bloqueado), al desbloquear el dispositivo después de cierto tiempo (variable, a veces minutos), la interfaz de usuario se muestra completamente negra, sin capacidad de interacción. El usuario se ve obligado a cerrar la aplicación desde el administrador de tareas para detener la reproducción y recuperar la funcionalidad. Este bug es crítico porque interrumpe la experiencia y puede generar frustración.

Objetivo:
Implementar persistencia local para todas las preferencias de reproducción y el estado de la sesión, y diagnosticar/corregir el bug de pantalla negra que ocurre al reanudar la app desde segundo plano. La solución debe ser robusta, mantener la arquitectura DDD, no usar setState, y cumplir con los estándares de seguridad y calidad establecidos.

Parte A: Persistencia de estado
Requisitos funcionales
Persistir modo de repetición

Al cambiar entre off, once, all, el valor debe guardarse en almacenamiento local (por ejemplo, SharedPreferences, Hive o sqflite, según la infraestructura existente).

Al iniciar la app, el AudioPlayerCubit debe restaurar el último modo de repetición seleccionado.

Persistir reproducción aleatoria

El estado de isShuffleEnabled debe guardarse y restaurarse automáticamente.

Persistir última pista seleccionada

Guardar el id de la última pista reproducida, junto con su posición en la lista (índice) y la posición de reproducción (milisegundos) si es factible.

Al reabrir la app, la lista debe hacer scroll automático hasta la pista guardada y resaltarla visualmente (por ejemplo, con un borde o fondo distinto) sin reproducirla automáticamente (a menos que se especifique).

Restaurar contexto de sesión

Si la app se cierra durante la reproducción, al reabrirla se debe mostrar la última pista seleccionada con su estado (pausada, no reproduciendo automáticamente para evitar sorpresas, salvo que exista configuración para auto-reanudar).

Los controles (shuffle, repeat) deben reflejar visualmente los valores persistidos.

Tareas de implementación
Crear o extender repositorio de preferencias

En la capa de infraestructura, crear PreferencesRepository (o similar) que abstraiga el almacenamiento clave-valor.

Métodos: saveRepeatMode(RepeatMode), getRepeatMode(), saveShuffleEnabled(bool), isShuffleEnabled(), saveLastTrack(Track, int index, Duration position), getLastTrack().

Integrar con AudioPlayerCubit

Al inicializar el cubit, cargar las preferencias guardadas y emitir el estado inicial con esos valores.

Cada vez que el usuario cambie el modo de repetición, active/desactive shuffle, o reproduzca una nueva pista, guardar automáticamente en el repositorio (sin bloquear la UI).

Actualizar la UI para restaurar scroll y resaltado

Al construir la lista de pistas, si existe una pista guardada y no se está reproduciendo automáticamente, usar un ScrollController con initialScrollOffset o hacer scroll programático tras el primer frame.

Resaltar el ítem correspondiente (por ejemplo, con un color de fondo sutil) usando el estado del cubit.

Manejo de errores de persistencia

Si falla la lectura/escritura, no romper la app; usar valores por defecto y loguear el error (sin exponer información sensible).

Pruebas

Verificar que al cerrar y abrir la app, los botones de repetición y shuffle muestran el estado correcto.

Probar que la última pista seleccionada se resalta y se hace scroll a su posición.

Parte B: Corrección de pantalla negra
Diagnóstico inicial (posibles causas)
Fuga de memoria o acumulación de widgets

Al reanudar desde background, Flutter puede estar reconstruyendo la pantalla de forma ineficiente, agotando la GPU o causando un deadlock en el hilo de UI.

Conflicto con el servicio de audio en primer plano

El AudioHandler de audio_service puede estar emitiendo estados que provocan un rebuild masivo al volver a la app, congelando la UI temporalmente o dejándola en negro si hay un error no capturado.

Problema con MediaQuery o SafeArea al reanudar

Al regresar del lock screen, el contexto puede no estar listo, causando que MediaQuery.of(context) devuelva valores incorrectos (0 o nulos), y por ende la UI no se renderiza.

Uso incorrecto de BlocBuilder o BlocListener

Si hay un BlocListener que no maneja correctamente el estado AppLifecycleState, podría estar cerrando la pantalla o mostrando un overlay negro.

Falta de RepaintBoundary o AddAutomaticKeepAlive

Widgets pesados que no se mantienen vivos correctamente pueden causar parpadeos o pantallas negras al volver.

Tareas de corrección
Reproducir el bug

Probar en dispositivos físicos (Android e iOS) con distintos tiempos de bloqueo (30 s, 1 min, 5 min, 10 min).

Registrar logs con flutter logs para capturar excepciones o avisos durante la transición.

Revisar ciclo de vida de la app

Implementar WidgetsBindingObserver en el widget raíz para manejar AppLifecycleState.paused, resumed, inactive, detached.

Al reanudar (resumed), verificar si el widget tree sigue siendo válido y, si no, forzar una reconstrucción controlada.

Auditar el AudioHandler y la comunicación con el Cubit

Asegurarse de que el flujo de eventos desde el servicio de audio no sature el BlocBuilder principal.

Usar BlocSelector para aislar las partes de la UI que dependen del estado del reproductor.

Optimizar la reconstrucción al reanudar

Evitar setState o rebuilds masivos.

Utilizar const widgets donde sea posible y RepaintBoundary alrededor de la lista y el mini reproductor.

Manejo de errores global

Envolver el runApp con un ErrorWidget.builder personalizado que muestre un mensaje en lugar de pantalla negra ante errores de build.

Añadir un FlutterError.onError para loguear y, opcionalmente, reiniciar la UI.

Pruebas de estrés

Reproducir audio, bloquear pantalla, esperar varios intervalos, desbloquear y verificar que la UI responde.

Probar con y sin notificación activa, con y sin auriculares conectados.

Documentación del fix

Explicar la causa raíz encontrada y la solución aplicada.

Restricciones generales
Prohibido el uso de setState.

No modificar la lógica de negocio de otras funcionalidades.

Mantener la arquitectura DDD: la persistencia debe estar en infraestructura, no en la presentación.

No introducir dependencias sin justificación.

La seguridad sigue siendo prioridad: no almacenar datos sensibles sin cifrar, no loguear rutas de archivos ni tokens.

Ejecutar flutter analyze y corregir todos los issues.

Ejecutar dart format . antes de la entrega.

Criterios de aceptación
Persistencia
Al cerrar y abrir la app, el modo de repetición y el shuffle mantienen su último estado.

La última pista seleccionada se resalta visualmente y la lista hace scroll a ella (sin auto-reproducir).

La posición de reproducción se conserva (si se implementa) y se muestra en la barra de progreso.

No hay errores de lectura/escritura que afecten la experiencia.

Pantalla negra
Después de reproducir audio en segundo plano durante al menos 10 minutos con la pantalla bloqueada, al desbloquear la UI se muestra correctamente y es interactiva.

No se observan pantallas negras ni cuelgues en las pruebas realizadas.

Los logs no muestran excepciones no controladas durante la transición background→foreground.

Si ocurre un error inesperado, se muestra un mensaje de error amigable en lugar de pantalla negra.

Calidad
flutter analyze sin warnings.

dart format aplicado.

Documentación actualizada con los cambios y resultados.

Entregables
Rama fix/persistence-and-black-screen con todos los cambios.

Informe de diagnóstico del bug de pantalla negra (causa raíz y solución).

Documentación de la persistencia implementada.

Lista de archivos modificados y pruebas realizadas.
