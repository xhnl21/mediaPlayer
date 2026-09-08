import 'package:flutter/material.dart';
import 'package:media_player/core/core.dart';

import 'package:media_player/presentation/utils/responsive_extensions.dart';

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    required this.hintText,
    required this.onChanged,
    super.key,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final fieldHeight = context.h(0.052).clamp(42.0, 52.0);
    final horizontalPadding = context.padding(0.04).clamp(12.0, 24.0);

    return Container(
      height: fieldHeight,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(fieldHeight / 2),
      ),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Center(
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textLight,
            fontSize: context.sp(14),
          ),
          cursorColor: AppColors.textLight,
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.8),
              fontSize: context.sp(14),
            ),
            prefixIcon: prefixIcon,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              vertical: (fieldHeight - context.sp(14)) / 4,
            ),
          ),
        ),
      ),
    );
  }
}
