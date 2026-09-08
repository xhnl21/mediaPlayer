import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/widgets.dart';

class RadioFmScreen extends StatelessWidget {
  const RadioFmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: BlocBuilder<RadioCubit, RadioState>(
            builder: (context, state) {
              return Column(
                children: [
                  const SizedBox(height: 8),
                  // Header Title
                  Text(
                    'Radio FM',
                    style: AppTypography.displayMedium.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 20),

                  // Waveform spectrum tuner
                  InteractiveWaveformTuner(
                    currentFrequency: state.frequency.mhz,
                    onFrequencyChanged: (freq) {
                      context.read<RadioCubit>().tune(freq);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Media transport controls: Previous, Play/Pause, Next
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous_rounded,
                          color: AppColors.textLight,
                          size: 32,
                        ),
                        onPressed: () =>
                            context.read<RadioCubit>().previousStation(),
                      ),
                      const SizedBox(width: 24),
                      InkWell(
                        onTap: () =>
                            context.read<RadioCubit>().togglePlayback(),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                          ),
                          child: Icon(
                            state.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: AppColors.textLight,
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          color: AppColors.textLight,
                          size: 32,
                        ),
                        onPressed: () =>
                            context.read<RadioCubit>().nextStation(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Volume Slider with Speaker Icon
                  Row(
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            activeTrackColor: AppColors.accentCoral,
                            inactiveTrackColor: AppColors.textLight.withValues(
                              alpha: 0.3,
                            ),
                            thumbColor: AppColors.accentCoral,
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
                      const Icon(
                        Icons.volume_up_rounded,
                        color: AppColors.textLight,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Station Title and Description
                  Text(
                    state.currentStation?.name ?? 'Lorem Name',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.currentStation?.description ?? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textLight.withValues(alpha: 0.85),
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
