import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';
import 'package:media_player/presentation/widgets.dart';

class EqualizerScreen extends StatelessWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const presets = ['Lorem', 'Ipsum', 'Dolor', 'Sit', 'Amet'];
    final horizontalPadding = context.w(0.04).clamp(12.0, 24.0);
    final verticalPadding = context.h(0.012).clamp(6.0, 16.0);
    final faderHeight = (context.isLandscape ? context.h(0.24) : context.h(0.18))
        .clamp(100.0, 180.0);
    final btnWidth = context.w(0.46).clamp(140.0, 240.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: BlocBuilder<EqualizerCubit, EqualizerState>(
            builder: (context, state) {
              return Column(
                children: [
                  SizedBox(height: context.h(0.01).clamp(4.0, 12.0)),
                  // Title
                  Text(
                    'Dolor sit',
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: context.sp(22),
                    ),
                  ),
                  SizedBox(height: context.h(0.02).clamp(10.0, 20.0)),

                  // 6 Vertical Faders
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: state.setting.bands.map((band) {
                      return VerticalFaderSlider(
                        label: band.label,
                        value: band.gain.normalized,
                        height: faderHeight,
                        onChanged: (val) {
                          context.read<EqualizerCubit>().setBandGain(
                            band.id,
                            val,
                          );
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: context.h(0.02).clamp(10.0, 20.0)),

                  // Preset Tabs Row: Lorem, Ipsum, Dolor, Sit, Amet
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: presets.map((p) {
                      final isSelected = state.setting.selectedPreset == p;
                      return GestureDetector(
                        onTap: () =>
                            context.read<EqualizerCubit>().selectPreset(p),
                        child: Text(
                          p,
                          style: AppTypography.bodySmall.copyWith(
                            color: isSelected
                                ? AppColors.textLight
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.6,
                                  ),
                            fontSize: context.sp(12),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: context.h(0.028).clamp(14.0, 28.0)),

                  // 3 Rotary Knobs: Bass, Treble, Vocal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RotaryKnobWidget(
                        label: 'Bass',
                        value: state.setting.bass,
                        onChanged: (val) =>
                            context.read<EqualizerCubit>().setBass(val),
                      ),
                      RotaryKnobWidget(
                        label: 'Treble',
                        value: state.setting.treble,
                        onChanged: (val) =>
                            context.read<EqualizerCubit>().setTreble(val),
                      ),
                      RotaryKnobWidget(
                        label: 'Vocal',
                        value: state.setting.vocal,
                        onChanged: (val) =>
                            context.read<EqualizerCubit>().setVocal(val),
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(0.032).clamp(16.0, 32.0)),

                  // CREATE Button
                  CommonCoralButton(
                    text: 'CREATE',
                    width: btnWidth,
                    onPressed: () {
                      context.read<EqualizerCubit>().save();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Equalizer profile saved and encrypted',
                            style: TextStyle(fontSize: context.sp(13)),
                          ),
                          backgroundColor: AppColors.cardSurfaceLight,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: context.h(0.02).clamp(10.0, 20.0)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
