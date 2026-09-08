import 'package:flutter/material.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';

class CircularMicIndicator extends StatelessWidget {
  const CircularMicIndicator({
    required this.amplitude,
    required this.isRecording,
    super.key,
    this.size,
  });

  final double amplitude; // 0.0 to 1.0
  final bool isRecording;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final pulseScale = isRecording ? (1.0 + amplitude * 0.15) : 1.0;

    // Dynamically proportioned concentric circles
    final outerSize =
        size ??
        (context.isLandscape ? context.h(0.35) : context.w(0.50)).clamp(
          130.0,
          220.0,
        );
    final midSize = outerSize * 0.75;
    final innerSize = outerSize * 0.50;
    final iconRadius = innerSize * 0.54;

    return Center(
      child: Transform.scale(
        scale: pulseScale,
        child: Container(
          width: outerSize,
          height: outerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardSurfaceLight.withValues(alpha: 0.6),
            boxShadow: [
              if (isRecording)
                BoxShadow(
                  color: AppColors.accentCoral.withValues(alpha: 0.3),
                  blurRadius: 24,
                  spreadRadius: 8,
                ),
            ],
          ),
          child: Center(
            // Middle ring
            child: Container(
              width: midSize,
              height: midSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textLight.withValues(alpha: 0.85),
              ),
              child: Center(
                // Inner core
                child: Container(
                  width: innerSize,
                  height: innerSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cardSurface,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.mic_rounded,
                      size: iconRadius,
                      color: isRecording
                          ? AppColors.accentCoral
                          : AppColors.textLight,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
