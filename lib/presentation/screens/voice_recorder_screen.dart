import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';
import 'package:media_player/presentation/widgets.dart';

class VoiceRecorderScreen extends StatelessWidget {
  const VoiceRecorderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.w(0.06).clamp(16.0, 32.0);
    final verticalPadding = context.h(0.015).clamp(8.0, 20.0);
    final micSize = (context.isLandscape ? context.h(0.32) : context.w(0.48))
        .clamp(130.0, 210.0);
    final recordBtnSize = context.iconSize(66);
    final pauseBtnSize = context.iconSize(44);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: BlocBuilder<RecorderCubit, RecorderState>(
                    builder: (context, state) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top Dropdown Header: "Ipsum v"
                          Padding(
                            padding: EdgeInsets.only(top: context.h(0.01)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.selectedMemoTitle,
                                  style: AppTypography.titleMedium.copyWith(
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.bold,
                                    fontSize: context.sp(15),
                                  ),
                                ),
                                SizedBox(
                                  width: context.w(0.01).clamp(2.0, 6.0),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textLight,
                                  size: context.iconSize(20),
                                ),
                              ],
                            ),
                          ),

                          // Center circular mic visual
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: context.h(0.02).clamp(8.0, 20.0),
                            ),
                            child: CircularMicIndicator(
                              amplitude: state.amplitude,
                              isRecording: state.isRecording,
                              size: micSize,
                            ),
                          ),

                          // Timer Display & Wave progress bar
                          Column(
                            children: [
                              Text(
                                state.formattedDuration,
                                style: AppTypography.displayMedium.copyWith(
                                  fontSize: context.sp(24),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              SizedBox(
                                height: context.h(0.015).clamp(8.0, 16.0),
                              ),

                              // Progress bar with coral line
                              // Justified exception: 3px progress bar height
                              Container(
                                height: 3,
                                width: double.infinity,
                                color: AppColors.textLight.withValues(
                                  alpha: 0.3,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: state.isRecording ? 0.6 : 0.0,
                                    child: Container(
                                      color: AppColors.accentCoral,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Control Row: (+, ..., prev, play, next)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: context.h(0.015).clamp(6.0, 16.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.add_rounded,
                                    color: AppColors.textLight,
                                    size: context.iconSize(24),
                                  ),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.skip_previous_rounded,
                                    color: AppColors.textLight,
                                    size: context.iconSize(26),
                                  ),
                                  onPressed: () {},
                                ),
                                Container(
                                  width: pauseBtnSize,
                                  height: pauseBtnSize,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent,
                                  ),
                                  child: Icon(
                                    Icons.pause_rounded,
                                    color: AppColors.textLight,
                                    size: context.iconSize(32),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.skip_next_rounded,
                                    color: AppColors.textLight,
                                    size: context.iconSize(26),
                                  ),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.more_horiz_rounded,
                                    color: AppColors.textLight,
                                    size: context.iconSize(24),
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),

                          // Bottom Recording Action Buttons: Loop, Record Circle, Stop/Save
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: context.h(0.01).clamp(4.0, 12.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Loop / Repeat Icon
                                IconButton(
                                  icon: Icon(
                                    Icons.replay_rounded,
                                    color: AppColors.textLight,
                                    size: context.iconSize(26),
                                  ),
                                  onPressed: () {},
                                ),

                                // Record Button (Large Circle)
                                GestureDetector(
                                  onTap: () => context
                                      .read<RecorderCubit>()
                                      .toggleRecording(),
                                  child: Container(
                                    width: recordBtnSize,
                                    height: recordBtnSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: state.isRecording
                                          ? AppColors.accentCoral
                                          : AppColors.cardSurfaceLight,
                                      // Justified exception: 3px record button ring stroke
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
                                        size: recordBtnSize * 0.52,
                                      ),
                                    ),
                                  ),
                                ),

                                // Stop / Bookmark Icon
                                IconButton(
                                  icon: Icon(
                                    Icons.stop_circle_outlined,
                                    color: AppColors.textLight,
                                    size: context.iconSize(26),
                                  ),
                                  onPressed: () {
                                    if (state.isRecording) {
                                      context
                                          .read<RecorderCubit>()
                                          .toggleRecording();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
