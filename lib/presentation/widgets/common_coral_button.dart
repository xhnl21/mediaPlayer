import 'package:flutter/material.dart';
import 'package:media_player/core/core.dart';

import 'package:media_player/presentation/utils/responsive_extensions.dart';

class CommonCoralButton extends StatelessWidget {
  const CommonCoralButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.width,
    this.height,
    this.isOutlined = false,
  });

  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    // Dynamic height based on screen height, clamped within touch target standards
    final effectiveHeight = height ?? (context.h(0.055).clamp(42.0, 54.0));

    return SizedBox(
      width: width ?? double.infinity,
      height: effectiveHeight,
      child: Material(
        color: isOutlined ? Colors.transparent : AppColors.accentCoral,
        borderRadius: BorderRadius.circular(effectiveHeight / 2),
        elevation: isOutlined ? 0 : 2,
        shadowColor: AppColors.shadow,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(effectiveHeight / 2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(effectiveHeight / 2),
              // Justified exception: 1.5 constant stroke width per design system
              border: isOutlined
                  ? Border.all(color: AppColors.textLight, width: 1.5)
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textLight,
                fontSize: context.sp(14),
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
