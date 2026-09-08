import 'package:flutter/material.dart';
import 'package:media_player/core/core.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({super.key, this.size = 140});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardSurfaceLight.withValues(alpha: 0.5),
      ),
      child: Center(
        child: Container(
          width: size * 0.8,
          height: size * 0.8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardSurfaceLight,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left rounded vertical bar
                Container(
                  width: size * 0.12,
                  height: size * 0.42,
                  decoration: BoxDecoration(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.circular(size * 0.06),
                  ),
                ),
                SizedBox(width: size * 0.08),
                // Play triangle shape
                Icon(
                  Icons.play_arrow_rounded,
                  size: size * 0.48,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
