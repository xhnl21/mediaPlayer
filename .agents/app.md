Actúa como un ingeniero de software senior experto en Flutter, Dart, arquitectura de software y seguridad informática. Debes desarrollar una aplicación móvil desde cero siguiendo estrictamente las siguientes reglas. Si alguna instrucción no está clara, pregunta antes de asumir.

Objetivo
Desarrollar una app en Flutter y Dart desde cero, aplicando las mejores prácticas de la industria con un nivel de exigencia máximo.

Requisitos técnicos y de arquitectura

1. Cumplimiento normativo y estándares
   Aplicar de forma obsesiva las normas internacionales relevantes (ISO 27001, OWASP MASVS, GDPR si aplica, etc.).

Seguridad de nivel bancario: cifrado AES-256 para datos en reposo, TLS 1.3 para datos en tránsito, almacenamiento seguro de claves (Keychain/Keystore), autenticación robusta (OAuth2, biometría), prevención de inyección, hardening del sistema y auditoría de accesos.

2. Arquitectura DDD (Domain-Driven Design)
   Implementar una arquitectura limpia por capas estrictamente separadas:

Domain: entidades, value objects, agregados, repositorios abstractos y reglas de negocio.

Application: casos de uso, DTOs, interfaces.

Infrastructure: implementaciones de repositorios, fuentes de datos, servicios externos.

Presentation: UI y manejo de estado.

Ninguna capa debe conocer detalles de implementación de capas internas.

Las dependencias deben apuntar siempre hacia el dominio.

3. Manejo de estado
   Prohibido el uso de setState en cualquier widget.

Todo el estado debe gestionarse de forma reactiva mediante BloC / Cubit.

Los Cubits deben emitir estados inmutables y bien tipados.

No debe haber lógica de negocio en widgets, solo en Cubits y capas inferiores.

4. Capa de presentación (UI)
   La capa de diseño debe ser agnóstica y "tonta": no debe contener lógica de negocio, solo renderizar según el estado recibido del Cubit.

Los eventos de interacción del usuario deben delegarse al Cubit correspondiente.

Se debe respetar fielmente el diseño proporcionado en las imágenes o prototipos: colores, tipografías, espaciados, disposición de elementos, iconos, etc. No se permite modificar el diseño sin autorización explícita.

Proceso de desarrollo y control de calidad 5. Revisión de errores por archivo
Al terminar de escribir cada archivo .dart, ejecutar flutter analyze y corregir todos los avisos, warnings y errores antes de continuar con el siguiente.

Utilizar un linter estricto (por ejemplo, very_good_analysis o pedantic configurado con reglas adicionales) para garantizar calidad.

6. Formato de código
   Antes de dar por finalizada cualquier tarea o hito, ejecutar dart format . en el directorio del proyecto para asegurar un formato consistente.

El código debe seguir las guías de estilo oficiales de Dart/Flutter.

Criterios de aceptación
El proyecto compila sin errores.

flutter analyze no muestra ningún issue.

No existe ninguna llamada a setState en el código.

Todos los estados son manejados por Cubit/BLoC.

La separación de capas DDD es evidente y estricta.

La seguridad implementada cumple con los estándares indicados.

El diseño visual coincide con las imágenes de referencia.

El código está formateado con dart format.

Notas finales
Documenta las decisiones de arquitectura y seguridad en un archivo ARCHITECTURE.md.

Incluye pruebas unitarias y de widgets para validar los casos de uso y el comportamiento de los Cubits.

Prioriza la mantenibilidad, escalabilidad y legibilidad del código.

Si necesitas aclarar algo sobre el diseño, requisitos funcionales o restricciones, pregunta antes de implementar.
