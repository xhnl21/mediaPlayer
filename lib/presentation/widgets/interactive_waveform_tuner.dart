import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';

class InteractiveWaveformTuner extends StatelessWidget {
  const InteractiveWaveformTuner({
    required this.currentFrequency,
    required this.onFrequencyChanged,
    super.key,
    this.height,
  });

  final double currentFrequency;
  final ValueChanged<double> onFrequencyChanged;
  final double? height;

  static const List<double> scaleMarkers = [
    101.7,
    101.9,
    102.3,
    102.5,
    102.8,
    103.4,
  ];

  @override
  Widget build(BuildContext context) {
    final tunerHeight = height ?? (context.h(0.14).clamp(90.0, 150.0));
    final horizontalPadding = context.padding(0.04).clamp(12.0, 24.0);

    return Column(
      children: [
        // Waveform graphic with tuning pointer
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            final box = context.findRenderObject() as RenderBox?;
            if (box == null) return;
            final localX = details.localPosition.dx.clamp(0.0, box.size.width);
            final ratio = localX / box.size.width;
            final minFreq = scaleMarkers.first;
            final maxFreq = scaleMarkers.last;
            final freq = minFreq + ratio * (maxFreq - minFreq);
            onFrequencyChanged(double.parse(freq.toStringAsFixed(1)));
          },
          child: SizedBox(
            height: tunerHeight,
            width: double.infinity,
            child: CustomPaint(
              painter: _WaveformPainter(
                frequency: currentFrequency,
                minFreq: scaleMarkers.first,
                maxFreq: scaleMarkers.last,
              ),
            ),
          ),
        ),
        SizedBox(height: context.h(0.015).clamp(8.0, 16.0)),

        // Frequency numbers row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: scaleMarkers.map((marker) {
              final isSelected = (currentFrequency - marker).abs() < 0.15;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onFrequencyChanged(marker),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        marker.toStringAsFixed(1),
                        style: AppTypography.labelSmall.copyWith(
                          color: isSelected
                              ? AppColors.accentCoral
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: context.sp(isSelected ? 13 : 11),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.frequency,
    required this.minFreq,
    required this.maxFreq,
  });

  final double frequency;
  final double minFreq;
  final double maxFreq;

  @override
  void paint(Canvas canvas, Size size) {
    // Justified exception: 2.0 stroke width for waveform curve
    final wavePaint = Paint()
      ..color = AppColors.textLight.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final midY = size.height * 0.55;

    // Draw sinusoidal curved wave
    path.moveTo(0, midY);
    for (double x = 0; x <= size.width; x += 2) {
      final progress = x / size.width;
      final y =
          midY +
          math.sin(progress * math.pi * 5) * (size.height * 0.23) +
          math.sin(progress * math.pi * 9) * (size.height * 0.10);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, wavePaint);

    // Calculate position of frequency pin
    final norm = ((frequency - minFreq) / (maxFreq - minFreq)).clamp(0.0, 1.0);
    final pinX = norm * size.width;
    final pinY =
        midY +
        math.sin(norm * math.pi * 5) * (size.height * 0.23) +
        math.sin(norm * math.pi * 9) * (size.height * 0.10);

    // Draw vertical indicator line
    // Justified exception: 2.0 stroke width for indicator line
    final linePaint = Paint()
      ..color = AppColors.accentCoral
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(pinX, 8), Offset(pinX, size.height - 8), linePaint);

    // Draw circle marker on waveform
    final circlePaint = Paint()
      ..color = AppColors.accentCoral
      ..style = PaintingStyle.fill;
    final outerMarkerRadius = (size.height * 0.058).clamp(5.0, 8.0);
    canvas.drawCircle(Offset(pinX, pinY), outerMarkerRadius, circlePaint);

    final innerCirclePaint = Paint()
      ..color = AppColors.textLight
      ..style = PaintingStyle.fill;
    final innerMarkerRadius = (outerMarkerRadius * 0.5).clamp(2.5, 4.0);
    canvas.drawCircle(Offset(pinX, pinY), innerMarkerRadius, innerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.frequency != frequency;
  }
}
