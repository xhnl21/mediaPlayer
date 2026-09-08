import 'package:flutter/material.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';

class VerticalFaderSlider extends StatelessWidget {
  const VerticalFaderSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.height,
  });

  final String label;
  final double value; // 0.0 to 1.0
  final ValueChanged<double> onChanged;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final faderHeight = height ?? (context.h(0.18).clamp(110.0, 180.0));
    final faderWidth = (context.w(0.09)).clamp(30.0, 48.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Vertical track with coral thumb
        SizedBox(
          height: faderHeight,
          width: faderWidth,
          child: RotatedBox(
            quarterTurns: 3, // Rotate slider vertically (bottom to top)
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                // Justified exception: 3px track line
                trackHeight: 3,
                activeTrackColor: AppColors.textLight,
                inactiveTrackColor: AppColors.textLight.withValues(alpha: 0.4),
                thumbColor: AppColors.accentCoral,
                overlayColor: AppColors.accentCoral.withValues(alpha: 0.2),
                // Justified exception: 9px thumb radius per audio mixing board design
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
        SizedBox(height: context.h(0.008).clamp(4.0, 10.0)),

        // Frequency Label
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textLight,
            fontSize: context.sp(10),
          ),
        ),
      ],
    );
  }
}
