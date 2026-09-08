import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/domain/player.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';
import 'package:media_player/presentation/widgets.dart';

class PlaylistTracksScreen extends StatelessWidget {
  const PlaylistTracksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.w(0.04).clamp(12.0, 24.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: context.h(0.01).clamp(4.0, 12.0)),
            // Track list view
            Expanded(
              child: BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                builder: (context, state) {
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: context.h(0.01).clamp(6.0, 14.0),
                    ),
                    itemCount: state.tracks.length,
                    separatorBuilder: (_, index) =>
                        SizedBox(height: context.h(0.012).clamp(6.0, 14.0)),
                    itemBuilder: (context, index) {
                      final track = state.tracks[index];
                      final isCurrentPlaying =
                          state.currentTrack?.id == track.id;

                      return _TrackItemRow(
                        track: track,
                        isPlaying: isCurrentPlaying,
                        onTap: () =>
                            context.read<AudioPlayerCubit>().playTrack(track),
                        onToggleFavorite: () => context
                            .read<AudioPlayerCubit>()
                            .toggleFavorite(track.id),
                        onToggleSelect: () => context
                            .read<AudioPlayerCubit>()
                            .toggleSelect(track.id),
                      );
                    },
                  );
                },
              ),
            ),

            // Persistent Mini Player with audio progress & transport controls
            const MiniPlayerWidget(),
          ],
        ),
      ),
    );
  }
}

class _TrackItemRow extends StatelessWidget {
  const _TrackItemRow({
    required this.track,
    required this.isPlaying,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onToggleSelect,
  });

  final Track track;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleSelect;

  @override
  Widget build(BuildContext context) {
    final rowHeight = context.h(0.064).clamp(48.0, 60.0);
    final checkCircleSize = context.iconSize(26);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rowHeight / 2),
      child: Container(
        height: rowHeight,
        padding: EdgeInsets.symmetric(
          horizontal: context.w(0.035).clamp(10.0, 18.0),
        ),
        decoration: BoxDecoration(
          color: isPlaying
              ? AppColors.cardSurfaceLight
              : AppColors.cardSurface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(rowHeight / 2),
        ),
        child: Row(
          children: [
            // Checkbox circle
            GestureDetector(
              onTap: onToggleSelect,
              child: Container(
                width: checkCircleSize,
                height: checkCircleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: track.isSelected
                      ? AppColors.textLight.withValues(alpha: 0.9)
                      : Colors.transparent,
                  // Justified exception: 1.5 circle border width
                  border: Border.all(color: AppColors.textLight, width: 1.5),
                ),
                child: track.isSelected
                    ? Icon(
                        Icons.check,
                        size: context.iconSize(16),
                        color: AppColors.primaryTealDark,
                      )
                    : null,
              ),
            ),
            SizedBox(width: context.w(0.035).clamp(8.0, 16.0)),

            // Track titles
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textLight,
                      fontSize: context.sp(14),
                      fontWeight: isPlaying ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: context.h(0.003).clamp(1.0, 4.0)),
                  Text(
                    track.artist,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: context.sp(11),
                    ),
                  ),
                ],
              ),
            ),

            // Favorite Heart Icon
            IconButton(
              icon: Icon(
                track.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border_rounded,
                color: track.isFavorite
                    ? AppColors.accentCoral
                    : AppColors.textLight,
                size: context.iconSize(20),
              ),
              onPressed: onToggleFavorite,
            ),

            // Cart / More Options Icon
            IconButton(
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.textLight,
                size: context.iconSize(20),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added "${track.title}" to playlist collection',
                      style: TextStyle(fontSize: context.sp(12)),
                    ),
                    duration: const Duration(seconds: 1),
                    backgroundColor: AppColors.cardSurfaceLight,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
