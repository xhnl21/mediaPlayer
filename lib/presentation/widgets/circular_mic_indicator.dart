import 'package:flutter/material.dart';
import 'package:media_player/core/core.dart';

class CircularMicIndicator extends StatelessWidget {
  const CircularMicIndicator({
    required this.amplitude,
    required this.isRecording,
    super.key,
  });

  final double amplitude; // 0.0 to 1.0
  final bool isRecording;

  @override
  Widget build(BuildContext context) {
    // Dynamic pulse sizes
    final pulseScale = isRecording ? (1.0 + amplitude * 0.15) : 1.0;

    return Center(
      child: Transform.scale(
        scale: pulseScale,
        child: Container(
          width: 200,
          height: 200,
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
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textLight.withValues(alpha: 0.85),
              ),
              child: Center(
                // Inner core
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cardSurface,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.mic_rounded,
                      size: 54,
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
