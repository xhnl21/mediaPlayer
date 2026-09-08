import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/widgets.dart';

class MyPlaylistScreen extends StatelessWidget {
  const MyPlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Featured Playlist Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Red/Coral circle with white star
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentCoral,
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: AppColors.textLight,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Playlist Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Playlist',
                                style: AppTypography.titleLarge.copyWith(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'March 1 at 20:00\n100 songs / 155 minutes',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
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
                              width: 76,
                              height: 30,
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
                            const SizedBox(height: 6),
                            CommonCoralButton(
                              text: 'PLUS',
                              width: 76,
                              height: 30,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      _buildTab(
                        context,
                        title: 'Lorem ipsum',
                        isSelected: state.selectedTab == 'Lorem ipsum',
                      ),
                      const SizedBox(width: 24),
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
            const Divider(color: AppColors.divider, height: 16),

            // Track list
            Expanded(
              child: BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                builder: (context, state) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 6.0,
                    ),
                    itemCount: state.tracks.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final track = state.tracks[index];
                      return Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => context
                                  .read<AudioPlayerCubit>()
                                  .toggleSelect(track.id),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: track.isSelected
                                      ? AppColors.textLight
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: AppColors.textLight,
                                    width: 1.5,
                                  ),
                                ),
                                child: track.isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 15,
                                        color: AppColors.primaryTealDark,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.title,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    track.artist,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.shopping_cart_outlined,
                                color: AppColors.textLight,
                                size: 19,
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
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(height: 2, width: 32, color: AppColors.accentCoral),
        ],
      ),
    );
  }
}
