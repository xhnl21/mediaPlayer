import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';

import 'package:media_player/presentation/utils/responsive_extensions.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        final horizontalPadding = context.padding(0.05).clamp(14.0, 24.0);
        final verticalPadding = context.h(0.01).clamp(6.0, 12.0);
        final playBtnSize = context.iconSize(44);

        return RepaintBoundary(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: const BoxDecoration(
              color: AppColors.cardSurface,
              // Justified exception: 0.5 hairline divider
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 0.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Track Info
                if (state.currentTrack != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${state.currentTrack!.title} • ${state.currentTrack!.artist}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.bold,
                            fontSize: context.sp(11),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(0.003).clamp(1.0, 4.0)),
                ],

                // Progress timestamps
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.formattedPosition,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textLight,
                        fontSize: context.sp(11),
                      ),
                    ),
                    Text(
                      state.formattedDuration,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textLight,
                        fontSize: context.sp(11),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.h(0.005).clamp(2.0, 6.0)),

                // Progress slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    // Justified exception: 3px track height for precision audio seek
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
                      icon: Icon(
                        Icons.skip_previous_rounded,
                        color: AppColors.textLight,
                        size: context.iconSize(28),
                      ),
                      onPressed: () =>
                          context.read<AudioPlayerCubit>().previous(),
                    ),
                    SizedBox(width: context.w(0.06).clamp(16.0, 32.0)),
                    InkWell(
                      onTap: () =>
                          context.read<AudioPlayerCubit>().togglePlayPause(),
                      borderRadius: BorderRadius.circular(playBtnSize / 2),
                      child: Container(
                        width: playBtnSize,
                        height: playBtnSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: state.status == AudioPlayerStatus.loading
                            ? Center(
                                child: SizedBox(
                                  width: context.iconSize(22),
                                  height: context.iconSize(22),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.accentCoral,
                                  ),
                                ),
                              )
                            : Icon(
                                state.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: AppColors.textLight,
                                size: context.iconSize(34),
                              ),
                      ),
                    ),
                    SizedBox(width: context.w(0.06).clamp(16.0, 32.0)),
                    IconButton(
                      icon: Icon(
                        Icons.skip_next_rounded,
                        color: AppColors.textLight,
                        size: context.iconSize(28),
                      ),
                      onPressed: () => context.read<AudioPlayerCubit>().next(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
