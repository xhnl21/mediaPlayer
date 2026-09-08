Prompt para ingeniero senior Flutter/Dart – Mejora de funcionalidades en vista de reproducción de lista de pistas

Contexto:
Trabajamos en una aplicación Flutter/Dart con arquitectura DDD (Domain-Driven Design) estricta, gestión de estado reactiva mediante BLoC/Cubit y altos estándares de calidad. Actualmente, la pantalla ubicada en lib/presentation/screens/playlist_tracks_screen.dart muestra una lista de pistas de audio de una playlist y permite reproducción básica. Se requiere ampliar sus capacidades para ofrecer una experiencia de usuario más completa y personalizada, manteniendo la separación de responsabilidades y las buenas prácticas existentes.

Objetivo:
Implementar un conjunto de funcionalidades en la vista de pistas de una playlist, incluyendo modos de repetición, eliminación de audios, reproducción aleatoria, y una vista de favoritos persistida en base de datos local. Todo ello respetando la arquitectura DDD, el patrón BLoC y la prohibición absoluta de setState.

Funcionalidades a implementar

1. Modos de repetición
   Permitir al usuario seleccionar entre:

Repetir una vez: reproducir la pista actual nuevamente al finalizar.

Repetir indefinidamente: reproducir la pista actual en bucle hasta que el usuario lo desactive.

Sin repetición (estado por defecto).

El control debe ser accesible desde la interfaz de reproducción (por ejemplo, un botón que cicla entre los tres estados).

El estado del modo de repetición debe ser gestionado por el PlayerCubit (o un cubit dedicado a la playlist) y reflejarse en la UI de forma reactiva.

2. Eliminación de audios
   Permitir eliminar un audio individual de la playlist, con confirmación previa (diálogo modal).

Permitir eliminar múltiples audios seleccionándolos mediante un modo de selección múltiple (por ejemplo, long press para activar selección, checkboxes, o botón "Editar").

Al eliminar, la lista debe actualizarse inmediatamente y reflejar el cambio en el estado global.

La eliminación no debe eliminar el archivo físico del dispositivo, solo quitarlo de la playlist actual (a menos que se especifique lo contrario).

Toda la lógica de eliminación debe estar en el cubit correspondiente, no en la vista.

3. Reproducción aleatoria (shuffle)
   Añadir un botón para activar/desactivar la reproducción aleatoria de la playlist.

Cuando esté activo, al terminar una pista, la siguiente debe seleccionarse al azar (sin repetir hasta agotar todas si es posible).

El orden aleatorio debe ser predecible en pruebas y manejado por el cubit (por ejemplo, mantener una lista barajada internamente).

El estado de reproducción aleatoria debe reflejarse en la interfaz (icono resaltado).

4. Quitar icono de carrito de compra
   Eliminar de la vista cualquier referencia o widget relacionado con un "carrito de compra" (icono, botón, texto).

Asegurarse de que no queden imports innecesarios o dependencias relacionadas.

5. Vista de favoritos (corazón) con persistencia local
   Crear una nueva vista o sección dentro de la misma pantalla que muestre únicamente los audios marcados como favoritos por el usuario (icono de corazón).

El marcado de favorito debe poder realizarse desde la lista principal (por ejemplo, un corazón junto a cada pista).

La lista de favoritos debe persistir en una base de datos local (SQLite a través de sqflite, drift, o similar, según la infraestructura existente).

La base de datos debe almacenar al menos el identificador único del audio y su estado de favorito.

El cubit de favoritos debe cargar los favoritos al iniciar la pantalla y actualizar la UI reactivamente.

Se debe implementar un repositorio en la capa de infraestructura para abstraer el acceso a la BD, y una entidad de dominio para FavoriteTrack.

Requisitos de arquitectura y calidad
Respetar estrictamente la separación por capas DDD:

Domain: definir entidades (Track, FavoriteTrack), repositorios abstractos (PlaylistRepository, FavoritesRepository), casos de uso (RemoveTracks, ToggleFavorite, GetFavorites, etc.).

Application: crear/actualizar cubits (PlaylistCubit, PlayerCubit, FavoritesCubit) que orquesten los casos de uso y emitan estados inmutables.

Infrastructure: implementar repositorios concretos (BD local, servicios de reproducción) y proveer dependencias mediante inyección.

Presentation: la vista playlist_tracks_screen.dart debe ser "tonta", solo consumir estados mediante BlocBuilder/BlocListener y enviar eventos a los cubits.

Prohibido el uso de setState. Todo cambio de estado debe fluir a través de cubits y streams.

La UI debe ser responsive y adaptarse a distintos tamaños de pantalla, siguiendo las utilidades existentes (MediaQuery helpers) si las hay.

Seguridad: los datos locales deben almacenarse de forma segura (cifrado si es factible), y no se debe exponer información sensible en logs.

Manejo de errores: capturar y mostrar mensajes claros ante fallos en BD, reproducción, o eliminación.

Tareas detalladas
Análisis del código actual

Revisar playlist_tracks_screen.dart y los cubits/repositorios relacionados para entender el flujo actual.

Identificar puntos de extensión y posibles conflictos.

Implementar modos de repetición

Añadir un enum RepeatMode { off, once, all } en la capa de dominio.

Crear/actualizar el cubit del reproductor para manejar este estado y la lógica de repetición.

Actualizar la UI con un control (ej. botón ciclable) y reflejar el estado.

Implementar eliminación de audios

Añadir lógica en el cubit de playlist para eliminar una o varias pistas.

Diseñar la interfaz para selección múltiple (ej. modo edición con checkboxes).

Mostrar diálogo de confirmación antes de eliminar.

Implementar reproducción aleatoria

Añadir estado isShuffleEnabled en el cubit del reproductor.

Implementar lógica de barajado y selección de siguiente pista.

Añadir botón de shuffle en la UI.

Eliminar icono de carrito

Localizar y eliminar cualquier widget o código relacionado con carrito de compra en la vista.

Limpiar imports y dependencias no usadas.

Implementar favoritos con BD local

Elegir el paquete de BD local (preferiblemente sqflite o drift, evaluar compatibilidad).

Crear migración/esquema de tabla favorites (id, track_id, etc.).

Implementar repositorio de favoritos en infraestructura.

Crear caso de uso para cargar y alternar favoritos.

Crear FavoritesCubit que exponga lista de favoritos y permita marcar/desmarcar.

Añadir icono de corazón en cada pista de la lista y una vista filtrada de favoritos (puede ser una pestaña o pantalla separada).

Asegurar persistencia entre reinicios de la app.

Pruebas y aseguramiento de calidad

Escribir pruebas unitarias para los casos de uso y cubits (repetición, eliminación, shuffle, favoritos).

Pruebas de widgets para verificar interacciones de la UI.

Ejecutar flutter analyze y corregir todos los issues.

Ejecutar dart format ..

Documentación

Actualizar ARCHITECTURE.md o crear documentación específica sobre las nuevas funcionalidades.

Incluir instrucciones de uso y decisiones de diseño.

Restricciones
No modificar la lógica de negocio existente de otras pantallas.

No introducir dependencias innecesarias; justificar cualquier nueva.

Mantener la seguridad de nivel bancario: cifrar datos sensibles en BD si es necesario, nunca loguear tokens o rutas absolutas.

El código debe ser legible y seguir las guías oficiales de Dart/Flutter.

La interfaz debe respetar el diseño actual y adaptarse correctamente a diferentes tamaños (responsive).
