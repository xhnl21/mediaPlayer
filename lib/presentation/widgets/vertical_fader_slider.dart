import 'package:flutter/material.dart';
import 'package:media_player/core/core.dart';

class VerticalFaderSlider extends StatelessWidget {
  const VerticalFaderSlider({
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
        // Vertical track with coral thumb
        SizedBox(
          height: 160,
          width: 36,
          child: RotatedBox(
            quarterTurns: 3, // Rotate slider vertically (bottom to top)
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                activeTrackColor: AppColors.textLight,
                inactiveTrackColor: AppColors.textLight.withValues(alpha: 0.4),
                thumbColor: AppColors.accentCoral,
                overlayColor: AppColors.accentCoral.withValues(alpha: 0.2),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 9,
                  elevation: 2,
                ),
                trackShape: const RectangularSliderTrackShape(),
              ),
              child: Slider(value: value.clamp(0.0, 1.0), onChanged: onChanged),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Frequency Label
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textLight,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
