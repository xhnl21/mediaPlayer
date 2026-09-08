import 'package:flutter/material.dart';
import 'package:media_player/core/core.dart';

import 'package:media_player/presentation/utils/responsive_extensions.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    // Dynamic size based on viewport width with safe accessibility clamps
    final effectiveSize = size ?? (context.w(0.38).clamp(100.0, 200.0));

    return Container(
      width: effectiveSize,
      height: effectiveSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardSurfaceLight.withValues(alpha: 0.5),
      ),
      child: Center(
        child: Container(
          width: effectiveSize * 0.8,
          height: effectiveSize * 0.8,
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
                  width: effectiveSize * 0.12,
                  height: effectiveSize * 0.42,
                  decoration: BoxDecoration(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.circular(effectiveSize * 0.06),
                  ),
                ),
                SizedBox(width: effectiveSize * 0.08),
                // Play triangle shape
                Icon(
                  Icons.play_arrow_rounded,
                  size: effectiveSize * 0.48,
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
