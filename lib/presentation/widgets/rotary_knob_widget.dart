import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';

class RotaryKnobWidget extends StatelessWidget {
  const RotaryKnobWidget({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.size,
  });

  final String label;
  final double value; // 0.0 to 1.0
  final ValueChanged<double> onChanged;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final knobSize = size ?? (context.w(0.15).clamp(48.0, 72.0));

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
            width: knobSize,
            height: knobSize,
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
        SizedBox(height: context.h(0.008).clamp(4.0, 8.0)),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textLight,
            fontSize: context.sp(11),
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
    // Justified exception: 4px offset margin for outer ring
    final radius = size.width / 2 - 4;

    // Outer subtle ring
    // Justified exception: 2.0px stroke width for ring outline
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

    final dotDistance = radius - (size.width * 0.12);
    final dotX = center.dx + dotDistance * math.cos(currentAngle);
    final dotY = center.dy + dotDistance * math.sin(currentAngle);

    final dotPaint = Paint()
      ..color = AppColors.accentCoral
      ..style = PaintingStyle.fill;
    final dotRadius = (size.width * 0.06).clamp(2.5, 4.5);
    canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _KnobPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
