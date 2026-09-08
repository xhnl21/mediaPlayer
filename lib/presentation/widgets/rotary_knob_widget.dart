import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:media_player/core/core.dart';

class RotaryKnobWidget extends StatelessWidget {
  const RotaryKnobWidget({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final double value; // 0.0 to 1.0
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onPanUpdate: (details) {
            // Drag up to increase, down to decrease
            final delta = -details.delta.dy * 0.01;
            onChanged((value + delta).clamp(0.0, 1.0));
          },
          child: Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardSurfaceLight,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: CustomPaint(painter: _KnobPainter(value: value)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _KnobPainter extends CustomPainter {
  _KnobPainter({required this.value});

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Outer subtle ring
    final ringPaint = Paint()
      ..color = AppColors.textLight.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, ringPaint);

    // Indicator dot on knob
    // Angle spans from -135 deg to +135 deg (total 270 deg)
    const startAngle = 135.0 * (math.pi / 180.0);
    final sweep = 270.0 * (math.pi / 180.0) * value;
    final currentAngle = startAngle + sweep;

    final dotDistance = radius - 8;
    final dotX = center.dx + dotDistance * math.cos(currentAngle);
    final dotY = center.dy + dotDistance * math.sin(currentAngle);

    final dotPaint = Paint()
      ..color = AppColors.accentCoral
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(dotX, dotY), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _KnobPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
