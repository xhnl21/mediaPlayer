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
        child: BlocConsumer<AudioPlayerCubit, AudioPlayerState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage!,
                    style: TextStyle(fontSize: context.sp(12)),
                  ),
                  backgroundColor: AppColors.accentCoral,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: AppColors.textLight,
                    onPressed: () {
                      context.read<AudioPlayerCubit>().dismissError();
                    },
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Top header bar with title & refresh button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: context.h(0.008).clamp(4.0, 10.0),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Device Tracks (${state.tracks.length})',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.bold,
                          fontSize: context.sp(15),
                        ),
                      ),
                      const Spacer(),
                      if (state.isLoadingTracks)
                        SizedBox(
                          width: context.iconSize(20),
                          height: context.iconSize(20),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accentCoral,
                          ),
                        )
                      else
                        IconButton(
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: AppColors.textLight,
                            size: context.iconSize(22),
                          ),
                          tooltip: 'Rescan Device Audio',
                          onPressed: () {
                            context.read<AudioPlayerCubit>().refreshLibrary();
                          },
                        ),
                    ],
                  ),
                ),

                // Permission Warning Banner if denied
                if (state.permissionStatus == AudioPermissionStatus.denied ||
                    state.permissionStatus ==
                        AudioPermissionStatus.permanentlyDenied)
                  _PermissionBanner(
                    onGrantPressed: () {
                      context
                          .read<AudioPlayerCubit>()
                          .requestPermissionsAndScan();
                    },
                  ),

                // Track list view or Empty/Loading State
                Expanded(
                  child: _buildContent(context, state, horizontalPadding),
                ),

                // Persistent Mini Player with audio progress & transport controls
                const MiniPlayerWidget(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AudioPlayerState state,
    double horizontalPadding,
  ) {
    if (state.isLoadingTracks && state.tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.accentCoral),
            SizedBox(height: context.h(0.02).clamp(10.0, 20.0)),
            Text(
              'Scanning local audio files...',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: context.sp(13),
              ),
            ),
          ],
        ),
      );
    }

    if (state.tracks.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding * 1.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.music_off_rounded,
                size: context.iconSize(56),
                color: AppColors.textSecondary.withValues(alpha: 0.6),
              ),
              SizedBox(height: context.h(0.015).clamp(8.0, 16.0)),
              Text(
                'No local audio tracks found',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textLight,
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.h(0.008).clamp(4.0, 10.0)),
              Text(
                'Transfer audio files (MP3, WAV, AAC, FLAC) to your device or grant storage permissions.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: context.sp(12),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.h(0.025).clamp(14.0, 26.0)),
              CommonCoralButton(
                text: 'RESCAN AUDIO',
                width: context.w(0.48).clamp(140.0, 220.0),
                onPressed: () {
                  context.read<AudioPlayerCubit>().requestPermissionsAndScan();
                },
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accentCoral,
      backgroundColor: AppColors.cardSurface,
      onRefresh: () async {
        await context.read<AudioPlayerCubit>().refreshLibrary();
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: context.h(0.01).clamp(6.0, 14.0),
        ),
        itemCount: state.tracks.length,
        separatorBuilder: (_, index) =>
            SizedBox(height: context.h(0.012).clamp(6.0, 14.0)),
        itemBuilder: (context, index) {
          final track = state.tracks[index];
          final isCurrentPlaying = state.currentTrack?.id == track.id;

          return _TrackItemRow(
            track: track,
            isPlaying: isCurrentPlaying,
            onTap: () => context.read<AudioPlayerCubit>().playTrack(track),
            onToggleFavorite: () =>
                context.read<AudioPlayerCubit>().toggleFavorite(track.id),
            onToggleSelect: () =>
                context.read<AudioPlayerCubit>().toggleSelect(track.id),
          );
        },
      ),
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({required this.onGrantPressed});

  final VoidCallback onGrantPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.w(0.04).clamp(12.0, 20.0),
        vertical: context.h(0.006).clamp(3.0, 8.0),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.w(0.035).clamp(10.0, 18.0),
        vertical: context.h(0.012).clamp(8.0, 14.0),
      ),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceLight,
        borderRadius: BorderRadius.circular(context.w(0.03).clamp(8.0, 14.0)),
        border: Border.all(
          color: AppColors.accentCoral.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_clock_rounded,
            color: AppColors.accentCoral,
            size: context.iconSize(24),
          ),
          SizedBox(width: context.w(0.03).clamp(8.0, 14.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permission Required',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: context.sp(12),
                  ),
                ),
                Text(
                  'Audio access is needed to play local files.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: context.sp(10),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.w(0.02).clamp(4.0, 10.0)),
          TextButton(
            onPressed: onGrantPressed,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(0.025).clamp(8.0, 14.0),
              ),
              backgroundColor: AppColors.accentCoral,
              foregroundColor: AppColors.textLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'GRANT',
              style: TextStyle(
                fontSize: context.sp(11),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textLight,
                      fontSize: context.sp(14),
                      fontWeight: isPlaying ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: context.h(0.003).clamp(1.0, 4.0)),
                  Text(
                    '${track.artist}${track.album.isNotEmpty ? " • ${track.album}" : ""} • ${track.formattedDuration}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
