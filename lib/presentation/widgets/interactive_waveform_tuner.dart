import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:media_player/core/core.dart';

class InteractiveWaveformTuner extends StatelessWidget {
  const InteractiveWaveformTuner({
    required this.currentFrequency,
    required this.onFrequencyChanged,
    super.key,
  });

  final double currentFrequency;
  final ValueChanged<double> onFrequencyChanged;

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
            height: 120,
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
        const SizedBox(height: 12),

        // Frequency numbers row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: scaleMarkers.map((marker) {
              final isSelected = (currentFrequency - marker).abs() < 0.15;
              return GestureDetector(
                onTap: () => onFrequencyChanged(marker),
                child: Text(
                  marker.toStringAsFixed(1),
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected
                        ? AppColors.accentCoral
                        : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: isSelected ? 13 : 11,
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
          math.sin(progress * math.pi * 5) * 28 +
          math.sin(progress * math.pi * 9) * 12;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, wavePaint);

    // Calculate position of frequency pin
    final norm = ((frequency - minFreq) / (maxFreq - minFreq)).clamp(0.0, 1.0);
    final pinX = norm * size.width;
    final pinY =
        midY +
        math.sin(norm * math.pi * 5) * 28 +
        math.sin(norm * math.pi * 9) * 12;

    // Draw vertical indicator line
    final linePaint = Paint()
      ..color = AppColors.accentCoral
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(pinX, 10),
      Offset(pinX, size.height - 10),
      linePaint,
    );

    // Draw circle marker on waveform
    final circlePaint = Paint()
      ..color = AppColors.accentCoral
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(pinX, pinY), 7, circlePaint);

    final innerCirclePaint = Paint()
      ..color = AppColors.textLight
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(pinX, pinY), 3.5, innerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.frequency != frequency;
  }
}
