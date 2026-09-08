import 'package:flutter/material.dart';
import 'package:media_player/core/core.dart';

class CommonCoralButton extends StatelessWidget {
  const CommonCoralButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.width,
    this.height = 46,
    this.isOutlined = false,
  });

  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: isOutlined ? Colors.transparent : AppColors.accentCoral,
        borderRadius: BorderRadius.circular(height / 2),
        elevation: isOutlined ? 0 : 2,
        shadowColor: AppColors.shadow,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(height / 2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              border: isOutlined
                  ? Border.all(color: AppColors.textLight, width: 1.5)
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textLight,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
