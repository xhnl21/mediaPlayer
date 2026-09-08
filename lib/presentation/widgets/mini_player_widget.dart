import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.cardSurface,
            border: Border(
              top: BorderSide(color: AppColors.divider, width: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress timestamps
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.formattedPosition,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  Text(
                    state.formattedDuration,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Progress slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  activeTrackColor: AppColors.accentCoral,
                  inactiveTrackColor: AppColors.textLight.withValues(
                    alpha: 0.3,
                  ),
                  thumbColor: AppColors.accentCoral,
                ),
                child: Slider(
                  value: state.progressNormalized,
                  onChanged: (val) {
                    final targetMillis = (val * state.duration.inMilliseconds)
                        .toInt();
                    context.read<AudioPlayerCubit>().seek(
                      Duration(milliseconds: targetMillis),
                    );
                  },
                ),
              ),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.skip_previous_rounded,
                      color: AppColors.textLight,
                      size: 28,
                    ),
                    onPressed: () =>
                        context.read<AudioPlayerCubit>().previous(),
                  ),
                  const SizedBox(width: 24),
                  InkWell(
                    onTap: () =>
                        context.read<AudioPlayerCubit>().togglePlayPause(),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: Icon(
                        state.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.textLight,
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      color: AppColors.textLight,
                      size: 28,
                    ),
                    onPressed: () => context.read<AudioPlayerCubit>().next(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
