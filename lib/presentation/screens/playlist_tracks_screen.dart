import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/domain/player.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/widgets.dart';

class PlaylistTracksScreen extends StatelessWidget {
  const PlaylistTracksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Track list view
            Expanded(
              child: BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                builder: (context, state) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: state.tracks.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isPlaying
              ? AppColors.cardSurfaceLight
              : AppColors.cardSurface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            // Checkbox circle
            GestureDetector(
              onTap: onToggleSelect,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: track.isSelected
                      ? AppColors.textLight.withValues(alpha: 0.9)
                      : Colors.transparent,
                  border: Border.all(color: AppColors.textLight, width: 1.5),
                ),
                child: track.isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.primaryTealDark,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),

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
                      fontSize: 14,
                      fontWeight: isPlaying ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    track.artist,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
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
                size: 20,
              ),
              onPressed: onToggleFavorite,
            ),

            // Cart / More Options Icon
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.textLight,
                size: 20,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added "${track.title}" to playlist collection',
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
