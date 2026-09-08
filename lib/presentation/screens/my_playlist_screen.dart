import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';
import 'package:media_player/presentation/widgets.dart';

class MyPlaylistScreen extends StatelessWidget {
  const MyPlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.w(0.04).clamp(12.0, 24.0);
    final cardPadding = context.w(0.04).clamp(12.0, 20.0);
    final starSize = context.w(0.14).clamp(44.0, 64.0);
    final btnWidth = context.w(0.20).clamp(68.0, 92.0);
    final btnHeight = context.h(0.038).clamp(28.0, 36.0);
    final rowHeight = context.h(0.062).clamp(46.0, 58.0);
    final checkCircleSize = context.iconSize(24);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Featured Playlist Card
            Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Container(
                padding: EdgeInsets.all(cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(context.w(0.05).clamp(14.0, 22.0)),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Red/Coral circle with white star
                        Container(
                          width: starSize,
                          height: starSize,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentCoral,
                          ),
                          child: Icon(
                            Icons.star_rounded,
                            color: AppColors.textLight,
                            size: starSize * 0.64,
                          ),
                        ),
                        SizedBox(width: context.w(0.035).clamp(8.0, 16.0)),
                        // Playlist Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Playlist',
                                style: AppTypography.titleLarge.copyWith(
                                  fontSize: context.sp(19),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: context.h(0.005).clamp(2.0, 6.0)),
                              Text(
                                'March 1 at 20:00\n100 songs / 155 minutes',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: context.sp(11),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Buttons LISTEN & PLUS
                        Column(
                          children: [
                            CommonCoralButton(
                              text: 'LISTEN',
                              width: btnWidth,
                              height: btnHeight,
                              onPressed: () {
                                final tracks = context
                                    .read<AudioPlayerCubit>()
                                    .state
                                    .tracks;
                                if (tracks.isNotEmpty) {
                                  context.read<AudioPlayerCubit>().playTrack(
                                    tracks.first,
                                  );
                                }
                              },
                            ),
                            SizedBox(height: context.h(0.008).clamp(4.0, 8.0)),
                            CommonCoralButton(
                              text: 'PLUS',
                              width: btnWidth,
                              height: btnHeight,
                              isOutlined: true,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Created new playlist entry'),
                                    backgroundColor: AppColors.cardSurfaceLight,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Tab bar: "Lorem ipsum" | "Lorem dolor"
            BlocBuilder<LibraryCubit, LibraryState>(
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(0.05).clamp(14.0, 24.0),
                  ),
                  child: Row(
                    children: [
                      _buildTab(
                        context,
                        title: 'Lorem ipsum',
                        isSelected: state.selectedTab == 'Lorem ipsum',
                      ),
                      SizedBox(width: context.w(0.06).clamp(16.0, 32.0)),
                      _buildTab(
                        context,
                        title: 'Lorem dolor',
                        isSelected: state.selectedTab == 'Lorem dolor',
                      ),
                    ],
                  ),
                );
              },
            ),
            Divider(
              color: AppColors.divider,
              height: context.h(0.02).clamp(10.0, 20.0),
            ),

            // Track list
            Expanded(
              child: BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                builder: (context, state) {
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: context.h(0.008).clamp(4.0, 10.0),
                    ),
                    itemCount: state.tracks.length,
                    separatorBuilder: (_, index) =>
                        SizedBox(height: context.h(0.01).clamp(6.0, 12.0)),
                    itemBuilder: (context, index) {
                      final track = state.tracks[index];
                      return Container(
                        height: rowHeight,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.w(0.03).clamp(8.0, 16.0),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(rowHeight / 2),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => context
                                  .read<AudioPlayerCubit>()
                                  .toggleSelect(track.id),
                              child: Container(
                                width: checkCircleSize,
                                height: checkCircleSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: track.isSelected
                                      ? AppColors.textLight
                                      : Colors.transparent,
                                  // Justified exception: 1.5 circle stroke
                                  border: Border.all(
                                    color: AppColors.textLight,
                                    width: 1.5,
                                  ),
                                ),
                                child: track.isSelected
                                    ? Icon(
                                        Icons.check,
                                        size: context.iconSize(15),
                                        color: AppColors.primaryTealDark,
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(width: context.w(0.03).clamp(8.0, 16.0)),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.title,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontSize: context.sp(13),
                                    ),
                                  ),
                                  Text(
                                    track.artist,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: context.sp(11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.shopping_cart_outlined,
                                color: AppColors.textLight,
                                size: context.iconSize(19),
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required String title,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => context.read<LibraryCubit>().selectTab(title),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: isSelected
                  ? AppColors.textLight
                  : AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: context.sp(14),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: context.h(0.005).clamp(2.0, 6.0)),
          if (isSelected)
            // Justified exception: 2px tab underline indicator
            Container(
              height: 2,
              width: context.w(0.08).clamp(24.0, 40.0),
              color: AppColors.accentCoral,
            ),
        ],
      ),
    );
  }
}
