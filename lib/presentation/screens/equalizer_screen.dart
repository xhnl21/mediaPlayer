import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/widgets.dart';

class EqualizerScreen extends StatelessWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const presets = ['Lorem', 'Ipsum', 'Dolor', 'Sit', 'Amet'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: BlocBuilder<EqualizerCubit, EqualizerState>(
            builder: (context, state) {
              return Column(
                children: [
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    'Dolor sit',
                    style: AppTypography.displayMedium.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 16),

                  // 6 Vertical Faders
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: state.setting.bands.map((band) {
                      return VerticalFaderSlider(
                        label: band.label,
                        value: band.gain.normalized,
                        onChanged: (val) {
                          context.read<EqualizerCubit>().setBandGain(
                            band.id,
                            val,
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

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
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

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
                  const SizedBox(height: 28),

                  // CREATE Button
                  CommonCoralButton(
                    text: 'CREATE',
                    width: 180,
                    onPressed: () {
                      context.read<EqualizerCubit>().save();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Equalizer profile saved and encrypted',
                          ),
                          backgroundColor: AppColors.cardSurfaceLight,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
