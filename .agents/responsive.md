Prompt mejorado para profesional senior Flutter/Dart
Objetivo
Transformar la capa de presentación del proyecto Flutter/Dart para que sea totalmente responsive, eliminando dimensiones fijas (width, height, padding, margin, SizedBox, Container, etc.) y sustituyéndolas por cálculos dinámicos basados en el tamaño y la orientación de la pantalla.

El resultado debe garantizar una experiencia visual correcta y sin overflows en múltiples dispositivos y orientaciones, sin alterar la lógica de negocio.

Alcance
Incluye: todas las vistas, componentes reutilizables, widgets de UI y estilos visuales.

Excluye: servicios, repositorios, controladores, modelos, estado global o cualquier lógica de negocio.

Tareas específicas

1. Auditoría de valores fijos
   Identificar todos los valores numéricos fijos en propiedades de presentación:

SizedBox(width: ..., height: ...)

Padding(padding: EdgeInsets.all(...))

Margin

Container(width: ..., height: ...)

Positioned(left: ..., top: ..., right: ..., bottom: ...)

TextStyle(fontSize: ...)

Icon(size: ...)

BorderRadius.circular(...)

Documentar cada hallazgo con archivo, línea y valor original.

2. Creación de utilidades responsivas
   Implementar extensiones sobre BuildContext u otros helpers reutilizables, por ejemplo:

dart
context.w(0.8) // 80% del ancho de pantalla
context.h(0.3) // 30% del alto de pantalla
context.padding(0.05) // padding proporcional
context.sp(16) // tamaño de fuente responsive escalado
context.iconSize(24) // tamaño de ícono responsive
Centralizar estas utilidades en un solo archivo (ej. responsive_extensions.dart) para evitar duplicación.

Usar MediaQuery.of(context).size como base, pero preferir LayoutBuilder cuando se necesite responder a restricciones de un widget específico (no de toda la pantalla).

3. Reemplazo de valores fijos
   Sustituir cada valor fijo por el helper responsivo correspondiente.

Mantener la intención de diseño original: si un elemento ocupaba el 50% del ancho, debe seguir haciéndolo proporcionalmente.

Para diseños complejos, usar LayoutBuilder y/o OrientationBuilder para adaptar la disposición según el espacio disponible y la orientación.

4. Adaptación a múltiples tamaños y orientaciones
   Asegurar que las vistas se ajusten correctamente en:

Teléfonos pequeños (360x640)

Teléfonos medianos/grandes (390x844, 414x896)

Tablets (768x1024)

Pantallas anchas/landscape (1280x800)

Verificar comportamiento en orientación vertical y horizontal.

Considerar el uso de SafeArea para evitar intrusiones con notch, status bar o gestos del sistema.

Evitar overflows: usar Flexible, Expanded, Wrap, SingleChildScrollView o FittedBox cuando sea necesario.

5. Texto e iconos escalables
   Escalar tamaños de fuente proporcionalmente al ancho/alto de pantalla usando el helper context.sp().

Ajustar tamaños de íconos mediante context.iconSize() para mantener jerarquía visual.

No usar tamaños fijos en TextStyle ni en Icon.

6. Excepciones justificadas
   Se permiten valores fijos solo en casos como:

Radios de borde pequeños e invariables.

Grosores de bordes (borderWidth).

Tamaños de íconos que por diseño deban permanecer constantes.

Todas las excepciones deben estar documentadas en el código con comentarios que expliquen el motivo.

7. Documentación
   Crear/actualizar un archivo RESPONSIVE_UI.md que incluya:

Utilidades creadas y cómo usarlas.

Pantallas modificadas y soluciones aplicadas.

Lista de excepciones justificadas.

Capturas de pantalla antes/después en las resoluciones indicadas (opcional pero recomendado).

Criterios de aceptación
No deben quedar valores fijos en propiedades de dimensionamiento, excepto las excepciones documentadas.

La interfaz debe visualizarse correctamente en al menos estas resoluciones:

360x640

390x844

414x896

768x1024

1280x800

El proyecto debe compilar sin errores ni warnings.

No debe haber overflows ni widgets recortados.

La lógica de negocio debe permanecer intacta.

Las utilidades responsivas deben ser reutilizables y estar correctamente nombradas.

Se debe entregar un informe breve con:

Pantallas modificadas.

Soluciones aplicadas.

Evidencia visual (capturas) en las resoluciones indicadas.

Entregables
Rama de trabajo: feature/responsive-ui

Pull request con los cambios listos para revisión.

Lista de archivos modificados (con breve descripción de cada cambio).

Reporte de revisión en formato Markdown o PDF:

Resumen de cambios.

Utilidades creadas.

Excepciones y justificación.

Capturas de pantalla por resolución/orientación.

Resultado de pruebas manuales/automáticas (si aplica).

Pruebas (opcional pero recomendado):

Widget tests que verifiquen la ausencia de overflows en diferentes tamaños.

Tests de las extensiones responsivas.

Notas adicionales para el desarrollador
Evitar llamar a MediaQuery.of(context) dentro de build de manera que provoque rebuilds innecesarios; si es posible, cachear el tamaño.

Priorizar LayoutBuilder sobre MediaQuery cuando el widget está dentro de un contenedor con restricciones propias.

Mantener el código limpio y consistente con la arquitectura actual del proyecto.

Si se detectan malas prácticas previas (por ejemplo, uso excesivo de SizedBox fijos), corregirlas como parte del cambio, siempre que no afecte la funcionalidad.

Ejemplo de implementación esperada
Antes:

dart
Container(
width: 300,
height: 150,
padding: EdgeInsets.all(16),
child: Text('Hola', style: TextStyle(fontSize: 18)),
)
Después:

dart
Container(
width: context.w(0.8),
height: context.h(0.2),
padding: EdgeInsets.all(context.w(0.04)),
child: Text('Hola', style: TextStyle(fontSize: context.sp(18))),
)
