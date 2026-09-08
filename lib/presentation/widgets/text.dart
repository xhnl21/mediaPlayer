// lib/presentation/widgets/text.dart

import 'package:flutter/material.dart';

/// Un widget de texto configurable y responsivo que soporta estilos heredados,
/// transformaciones de texto (mayúsculas, capitalización) y ajuste automático mediante [FittedBox].
class Texts extends StatelessWidget {
  /// Contenido textual a mostrar.
  final String text;

  /// Estilo base del texto. Si se especifican propiedades individuales
  /// como [fontSize], [fontWeight] o [color], estas sobrescribirán a las del [style].
  final TextStyle? style;

  /// Tamaño de la fuente tipográfica.
  final double? fontSize;

  /// Peso o grosor de la fuente tipográfica.
  final FontWeight? fontWeight;

  /// Color del texto.
  final Color? color;

  /// Alineación del texto dentro de su contenedor.
  final TextAlign? textAlign;

  /// Número máximo de líneas permitidas.
  final int? maxLines;

  /// Comportamiento ante el desbordamiento visual del texto.
  final TextOverflow? overflow;

  /// Decoración del texto (ej. subrayado, tachado).
  final TextDecoration? decoration;

  /// Color de la decoración del texto.
  final Color? decorationColor;

  /// Espaciado entre letras.
  final double? letterSpacing;

  /// Altura relativa de la línea de texto.
  final double? height;

  /// Estilo tipográfico (normal, cursiva).
  final FontStyle? fontStyle;

  /// Familia tipográfica.
  final String? fontFamily;

  /// Si el texto debe envolverse en saltos de línea suaves.
  final bool? softWrap;

  /// Si se debe transformar todo el texto a mayúsculas.
  final bool uppercase;

  /// Si se debe capitalizar la primera letra del texto.
  final bool capitalize;

  /// Si el widget debe envolverse en un [FittedBox] para escalar automáticamente
  /// evitando desbordamientos visuales.
  final bool fittedBox;

  /// Modo de ajuste de [FittedBox] cuando [fittedBox] es true (por defecto [BoxFit.scaleDown]).
  final BoxFit fit;

  /// Alineación de [FittedBox] cuando [fittedBox] es true.
  final AlignmentGeometry? alignment;

  /// Constructor constante del widget [Texts].
  const Texts(
    this.text, {
    super.key,
    this.style,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.decorationColor,
    this.letterSpacing,
    this.height,
    this.fontStyle,
    this.fontFamily,
    this.softWrap,
    this.uppercase = false,
    this.capitalize = false,
    this.fittedBox = false,
    this.fit = BoxFit.scaleDown,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Obtener el Theme actual y el DefaultTextStyle heredado
    final theme = Theme.of(context);
    final inheritedStyle = DefaultTextStyle.of(context).style;

    // 2. Obtener la fuente definida
    final defaultFontFamily =
        inheritedStyle.fontFamily ?? theme.textTheme.bodyMedium?.fontFamily;

    // 3. Definir valores por defecto desde el Theme o el estilo heredado
    final defaultColor = inheritedStyle.color ?? theme.colorScheme.onSurface;
    final defaultFontSize =
        inheritedStyle.fontSize ?? theme.textTheme.bodyMedium?.fontSize ?? 12.0;
    final defaultFontWeight =
        inheritedStyle.fontWeight ??
        theme.textTheme.bodyMedium?.fontWeight ??
        FontWeight.normal;

    // 4. Procesar el texto según las opciones
    String displayText = text;
    if (uppercase) {
      displayText = text.toUpperCase();
    } else if (capitalize) {
      displayText = _capitalize(text);
    }

    // 5. Construir estilo efectivo combinando style heredado/provisto y propiedades específicas
    final baseStyle = style ?? inheritedStyle;
    final effectiveStyle = baseStyle.copyWith(
      fontFamily: fontFamily ?? baseStyle.fontFamily ?? defaultFontFamily,
      fontSize:
          fontSize ?? (style != null ? baseStyle.fontSize : defaultFontSize),
      fontWeight:
          fontWeight ??
          (style != null ? baseStyle.fontWeight : defaultFontWeight),
      color: color ?? (style != null ? baseStyle.color : defaultColor),
      decoration: decoration ?? baseStyle.decoration,
      decorationColor: decorationColor ?? baseStyle.decorationColor,
      letterSpacing: letterSpacing ?? baseStyle.letterSpacing,
      height: height ?? baseStyle.height,
      fontStyle: fontStyle ?? baseStyle.fontStyle,
    );

    // 6. Crear el widget de texto base
    final textWidget = Text(
      displayText,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      style: effectiveStyle,
    );

    // 7. Envolver en FittedBox si es necesario
    if (fittedBox) {
      final effectiveAlignment =
          alignment ??
          (textAlign == TextAlign.center
              ? Alignment.center
              : (textAlign == TextAlign.right || textAlign == TextAlign.end)
              ? Alignment.centerRight
              : Alignment.centerLeft);

      return FittedBox(
        fit: fit,
        alignment: effectiveAlignment,
        child: textWidget,
      );
    }

    return textWidget;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
