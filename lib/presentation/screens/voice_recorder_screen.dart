import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/widgets.dart';

class VoiceRecorderScreen extends StatelessWidget {
  const VoiceRecorderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: BlocBuilder<RecorderCubit, RecorderState>(
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Dropdown Header: "Ipsum v"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.selectedMemoTitle,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textLight,
                        size: 20,
                      ),
                    ],
                  ),

                  // Center circular mic visual
                  CircularMicIndicator(
                    amplitude: state.amplitude,
                    isRecording: state.isRecording,
                  ),

                  // Timer Display & Wave progress bar
                  Column(
                    children: [
                      Text(
                        state.formattedDuration,
                        style: AppTypography.displayMedium.copyWith(
                          fontSize: 24,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Progress bar with coral line
                      Container(
                        height: 3,
                        width: double.infinity,
                        color: AppColors.textLight.withValues(alpha: 0.3),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: state.isRecording ? 0.6 : 0.0,
                            child: Container(color: AppColors.accentCoral),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Control Row: (+, ..., prev, play, next)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.add_rounded,
                          color: AppColors.textLight,
                          size: 24,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous_rounded,
                          color: AppColors.textLight,
                          size: 26,
                        ),
                        onPressed: () {},
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: const Icon(
                          Icons.pause_rounded,
                          color: AppColors.textLight,
                          size: 32,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          color: AppColors.textLight,
                          size: 26,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          color: AppColors.textLight,
                          size: 24,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  // Bottom Recording Action Buttons: Loop, Record Circle, Stop/Save
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Loop / Repeat Icon
                      IconButton(
                        icon: const Icon(
                          Icons.replay_rounded,
                          color: AppColors.textLight,
                          size: 26,
                        ),
                        onPressed: () {},
                      ),

                      // Record Button (Large Circle)
                      GestureDetector(
                        onTap: () =>
                            context.read<RecorderCubit>().toggleRecording(),
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: state.isRecording
                                ? AppColors.accentCoral
                                : AppColors.cardSurfaceLight,
                            border: Border.all(
                              color: AppColors.textLight,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              state.isRecording
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              color: AppColors.textLight,
                              size: 36,
                            ),
                          ),
                        ),
                      ),

                      // Stop / Bookmark Icon
                      IconButton(
                        icon: const Icon(
                          Icons.stop_circle_outlined,
                          color: AppColors.textLight,
                          size: 26,
                        ),
                        onPressed: () {
                          if (state.isRecording) {
                            context.read<RecorderCubit>().toggleRecording();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
