import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';
import 'package:media_player/presentation/widgets.dart';

class RadioFmScreen extends StatelessWidget {
  const RadioFmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.w(0.06).clamp(16.0, 32.0);
    final verticalPadding = context.h(0.015).clamp(8.0, 18.0);
    final transportSpacing = context.w(0.06).clamp(16.0, 32.0);
    final playBtnSize = context.iconSize(48);
    final tunerHeight =
        (context.isLandscape ? context.h(0.20) : context.h(0.14)).clamp(
          80.0,
          140.0,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: BlocBuilder<RadioCubit, RadioState>(
            builder: (context, state) {
              return Column(
                children: [
                  SizedBox(height: context.h(0.01).clamp(4.0, 12.0)),
                  // Header Title
                  Text(
                    'Radio FM',
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: context.sp(22),
                    ),
                  ),
                  SizedBox(height: context.h(0.024).clamp(12.0, 24.0)),

                  // Waveform spectrum tuner
                  InteractiveWaveformTuner(
                    currentFrequency: state.frequency.mhz,
                    height: tunerHeight,
                    onFrequencyChanged: (freq) {
                      context.read<RadioCubit>().tune(freq);
                    },
                  ),
                  SizedBox(height: context.h(0.028).clamp(14.0, 28.0)),

                  // Media transport controls: Previous, Play/Pause, Next
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.skip_previous_rounded,
                          color: AppColors.textLight,
                          size: context.iconSize(32),
                        ),
                        onPressed: () =>
                            context.read<RadioCubit>().previousStation(),
                      ),
                      SizedBox(width: transportSpacing),
                      InkWell(
                        onTap: () =>
                            context.read<RadioCubit>().togglePlayback(),
                        borderRadius: BorderRadius.circular(playBtnSize / 2),
                        child: Container(
                          width: playBtnSize,
                          height: playBtnSize,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                          ),
                          child: Icon(
                            state.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: AppColors.textLight,
                            size: context.iconSize(38),
                          ),
                        ),
                      ),
                      SizedBox(width: transportSpacing),
                      IconButton(
                        icon: Icon(
                          Icons.skip_next_rounded,
                          color: AppColors.textLight,
                          size: context.iconSize(32),
                        ),
                        onPressed: () =>
                            context.read<RadioCubit>().nextStation(),
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(0.018).clamp(10.0, 20.0)),

                  // Volume Slider with Speaker Icon
                  Row(
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            // Justified exception: 3px slider track
                            trackHeight: 3,
                            activeTrackColor: AppColors.accentCoral,
                            inactiveTrackColor: AppColors.textLight.withValues(
                              alpha: 0.3,
                            ),
                            thumbColor: AppColors.accentCoral,
                            // Justified exception: 6px thumb radius
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                          ),
                          child: Slider(
                            value: state.volume,
                            onChanged: (vol) =>
                                context.read<RadioCubit>().setVolume(vol),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.volume_up_rounded,
                        color: AppColors.textLight,
                        size: context.iconSize(20),
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(0.028).clamp(14.0, 28.0)),

                  // Station Title and Description
                  Text(
                    state.currentStation?.name ?? 'Lorem Name',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.sp(16),
                    ),
                  ),
                  SizedBox(height: context.h(0.01).clamp(4.0, 10.0)),
                  Text(
                    state.currentStation?.description ?? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textLight.withValues(alpha: 0.85),
                      fontSize: context.sp(12),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
