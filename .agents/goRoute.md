Plan de implementación de navegación con go_router en Flutter (Arquitectura DDD + BLoC)

1. Objetivo
   Integrar go_router como sistema de navegación declarativo y centralizado, alineado con la arquitectura DDD y el manejo de estado reactivo con BLoC/Cubit, garantizando:

Separación estricta entre capas.

Protección de rutas según autenticación.

Soporte para deep links.

Escalabilidad y mantenibilidad.

Cumplimiento de estándares de seguridad (redirecciones seguras, sin fugas de información).

2. Alcance
   Reemplazar cualquier navegación imperativa (Navigator.push, pushNamed) existente.

Definir todas las rutas de la aplicación en un único lugar (app_router.dart).

Implementar guards de autenticación basados en el estado del Cubit de sesión.

Manejar parámetros de ruta y query parameters.

Preparar el sistema para deep links.

Incluir pruebas unitarias y de widgets para la navegación.

3. Requisitos previos
   Proyecto Flutter con arquitectura DDD (carpetas domain, application, infrastructure, presentation).

Gestión de estado con BLoC/Cubit.

Mecanismo de autenticación definido (token, sesión).

Dependencias actuales: flutter_bloc, go_router.

4. Plan de trabajo detallado
   Fase 1: Configuración e integración de go_router
   Agregar dependencia
   Añadir go_router al pubspec.yaml en su versión estable más reciente.

yaml
dependencies:
go_router: ^14.0.0
Crear archivo central de rutas
En lib/presentation/router/app_router.dart, definir una clase AppRouter que contenga la configuración global.

Usar GoRouter con initialLocation, redirect, routes.

Definir un refreshListenable que combine los cambios del estado de autenticación (por ejemplo, un ValueNotifier alimentado por el Cubit de sesión).

Mantener la lógica de redirección simple y testable.

Definir constantes de rutas
Crear una clase abstracta RouteNames (o similar) con las rutas como constantes String.
Ejemplo:

dart
class RouteNames {
static const login = '/login';
static const home = '/home';
static const audioDetail = '/home/audio/:id';
static const settings = '/settings';
}
Configurar MaterialApp.router
En el widget raíz, reemplazar MaterialApp por MaterialApp.router y pasar routerConfig: AppRouter.router.

Eliminar cualquier uso de Navigator directo o onGenerateRoute.

Fase 2: Definición de rutas y pantallas
Mapear todas las pantallas de la aplicación
Listar todas las vistas existentes (login, registro, home, reproductor, configuración, etc.) y agruparlas según flujo.

Crear builders para cada ruta
Cada builder debe retornar el widget correspondiente, preferiblemente usando BlocProvider si el Cubit es específico de la pantalla, o consumiendo Cubits globales (como el de autenticación) mediante BlocProvider.value.

Rutas anidadas y sub-rutas
Si existen pantallas con navegación interna (tabs, detalles), usar ShellRoute o rutas anidadas con StatefulShellRoute si se necesita mantener estado.

Ejemplo: HomeShell con pestañas inferiores (Biblioteca, Explorar, Ajustes).

Manejo de parámetros

Rutas con parámetros dinámicos: /audio/:id.

Query parameters: /search?query=....

Usar GoRouterState.pathParameters o state.uri.queryParameters dentro del builder.

Fase 3: Integración con autenticación y redirecciones
Crear AuthState notifier

En el Cubit de autenticación (AuthCubit), exponer un Stream<AuthState> o un ValueNotifier<bool> que indique si el usuario está autenticado.

Este notifier será pasado al GoRouter como refreshListenable para que el router se actualice automáticamente ante cambios de sesión.

Implementar lógica de redirección
En la propiedad redirect del GoRouter:

Si el usuario no está autenticado y la ruta no es pública (login, registro, splash), redirigir a /login.

Si el usuario está autenticado y está en /login o /register, redirigir a /home.

Manejar rutas de error (404) redirigiendo a una pantalla de "no encontrado".

Proteger rutas sensibles

No exponer datos sensibles en la URL (por ejemplo, no incluir tokens).

Utilizar redirecciones antes de construir la pantalla para evitar fugas de información.

Fase 4: Deep links y navegación externa
Configurar deep links

En AndroidManifest.xml y Info.plist, definir los esquemas de URL y hosts permitidos.

En AppRouter, asegurarse de que las rutas están correctamente mapeadas para que los deep links abran la pantalla correspondiente.

Pruebas manuales de deep links

Probar en emulador y dispositivo físico: adb shell am start -a android.intent.action.VIEW -d "miapp://audio/123".

Validar que la redirección de autenticación funcione también para deep links (si no está logueado, redirigir a login y luego continuar).

Fase 5: Refactorización de navegación existente
Eliminar Navigator.push y pushNamed

Revisar todos los archivos de presentación y reemplazar por context.go(), context.push(), context.pop(), etc.

Ajustar los widgets que usaban MaterialPageRoute manual.

Actualizar pruebas de widgets

Las pruebas que dependían de la navegación deben usar MockGoRouter o configurar un GoRouter de prueba.

Verificar que no queden referencias a Navigator directo.

Fase 6: Pruebas y aseguramiento de calidad
Pruebas unitarias del router

Crear tests para AppRouter.redirect con diferentes estados de autenticación.

Probar que las rutas generan los builders correctos.

Pruebas de integración de navegación

Usar WidgetTester para simular tap en elementos y verificar que la navegación ocurre.

Probar deep links con GoRouter de prueba.

Ejecutar análisis estático

flutter analyze sin warnings.

dart format ..

Revisión de seguridad

Asegurar que no hay información sensible en URLs.

Validar que las redirecciones no permitan acceso no autorizado.

Fase 7: Documentación
Actualizar documentación de arquitectura

Añadir sección sobre navegación con go_router en ARCHITECTURE.md.

Documentar cómo agregar una nueva ruta y los patrones de redirección.

5. Consideraciones de arquitectura DDD
   El router pertenece a la capa de presentación (infraestructura de UI), pero no debe contener lógica de negocio.

Las decisiones de redirección se basan en el estado del Cubit de autenticación, que es la fuente de verdad.

Los builders deben ser simples y delegar la lógica a los Cubits correspondientes.

6. Criterios de aceptación
   Todas las rutas están definidas centralizadamente.

La navegación funciona correctamente en todas las pantallas.

La autenticación protege las rutas privadas y redirige según corresponda.

Deep links abren la pantalla esperada.

No hay llamadas directas a Navigator.push o pushNamed.

flutter analyze no reporta issues.

Pruebas unitarias y de widgets pasan exitosamente.

7. Entregables
   Rama feature/go-router-integration con todos los cambios.

Documentación actualizada.

Reporte de pruebas realizadas.
