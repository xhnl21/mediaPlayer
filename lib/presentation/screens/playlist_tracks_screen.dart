import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/domain/player.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';
import 'package:media_player/presentation/widgets.dart';

class PlaylistTracksScreen extends StatefulWidget {
  const PlaylistTracksScreen({super.key});

  @override
  State<PlaylistTracksScreen> createState() => _PlaylistTracksScreenState();
}

class _PlaylistTracksScreenState extends State<PlaylistTracksScreen> {
  final ValueNotifier<int> _selectedTabNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _selectedTabNotifier.dispose();
    super.dispose();
  }

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
          builder: (context, playerState) {
            return BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favState) {
                return Column(
                  children: [
                    // Top header: Selection Action Bar OR Normal Title Bar
                    if (playerState.isSelectionMode)
                      _buildSelectionHeader(
                        context,
                        playerState,
                        horizontalPadding,
                      )
                    else
                      _buildNormalHeader(
                        context,
                        playerState,
                        favState,
                        horizontalPadding,
                      ),

                    // Controls Toolbar: Tabs (All / Favorites) + Playback Controls
                    _buildControlsToolbar(
                      context,
                      playerState,
                      favState,
                      horizontalPadding,
                    ),

                    // Permission Banner
                    if (playerState.permissionStatus ==
                            AudioPermissionStatus.denied ||
                        playerState.permissionStatus ==
                            AudioPermissionStatus.permanentlyDenied)
                      _PermissionBanner(
                        onGrantPressed: () {
                          context
                              .read<AudioPlayerCubit>()
                              .requestPermissionsAndScan();
                        },
                      ),

                    // Main Content (All Tracks or Favorites Tab)
                    Expanded(
                      child: ValueListenableBuilder<int>(
                        valueListenable: _selectedTabNotifier,
                        builder: (context, activeTab, _) {
                          if (activeTab == 1) {
                            return _buildFavoritesTabContent(
                              context,
                              playerState,
                              favState,
                              horizontalPadding,
                            );
                          }
                          return _buildAllTracksTabContent(
                            context,
                            playerState,
                            favState,
                            horizontalPadding,
                          );
                        },
                      ),
                    ),

                    // Persistent Mini Player
                    const MiniPlayerWidget(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNormalHeader(
    BuildContext context,
    AudioPlayerState playerState,
    FavoritesState favState,
    double horizontalPadding,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: context.h(0.008).clamp(4.0, 10.0),
      ),
      child: Row(
        children: [
          Text(
            'Playlist Tracks',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
              fontSize: context.sp(16),
            ),
          ),
          const Spacer(),
          if (playerState.isLoadingTracks)
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
    );
  }

  Widget _buildSelectionHeader(
    BuildContext context,
    AudioPlayerState playerState,
    double horizontalPadding,
  ) {
    final selectedCount = playerState.selectedTrackIds.length;
    final totalCount = playerState.tracks.length;
    final allSelected = totalCount > 0 && selectedCount == totalCount;

    return Container(
      color: AppColors.cardSurfaceLight,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: context.h(0.006).clamp(4.0, 8.0),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              allSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: AppColors.textLight,
              size: context.iconSize(22),
            ),
            tooltip: allSelected ? 'Deselect All' : 'Select All',
            onPressed: () {
              if (allSelected) {
                context.read<AudioPlayerCubit>().clearSelection();
              } else {
                context.read<AudioPlayerCubit>().selectAllTracks();
              }
            },
          ),
          Text(
            '$selectedCount selected',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textLight,
              fontSize: context.sp(14),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (selectedCount > 0)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentCoral,
                foregroundColor: AppColors.textLight,
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(0.03).clamp(8.0, 16.0),
                  vertical: context.h(0.008).clamp(4.0, 10.0),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                Icons.delete_outline_rounded,
                size: context.iconSize(18),
              ),
              label: Text(
                'Delete ($selectedCount)',
                style: TextStyle(
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => _confirmBatchDelete(context, selectedCount),
            ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.textLight,
              size: context.iconSize(22),
            ),
            tooltip: 'Cancel Selection Mode',
            onPressed: () {
              context.read<AudioPlayerCubit>().toggleSelectionMode(false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlsToolbar(
    BuildContext context,
    AudioPlayerState playerState,
    FavoritesState favState,
    double horizontalPadding,
  ) {
    final iconBtnSize = context.iconSize(36).clamp(30.0, 40.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: context.h(0.006).clamp(3.0, 8.0),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth:
                MediaQuery.sizeOf(context).width - (horizontalPadding * 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Filter Tabs (All Tracks vs Favorites)
              ValueListenableBuilder<int>(
                valueListenable: _selectedTabNotifier,
                builder: (context, activeTab, _) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _FilterTabPill(
                          label: 'All (${playerState.tracks.length})',
                          isSelected: activeTab == 0,
                          onTap: () => _selectedTabNotifier.value = 0,
                        ),
                        _FilterTabPill(
                          label: 'Favorites (${favState.favorites.length})',
                          isSelected: activeTab == 1,
                          onTap: () => _selectedTabNotifier.value = 1,
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(width: context.w(0.02).clamp(4.0, 12.0)),

              // Action buttons row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Shuffle Button
                  IconButton(
                    constraints: BoxConstraints(
                      minWidth: iconBtnSize,
                      minHeight: iconBtnSize,
                    ),
                    padding: const EdgeInsets.all(4),
                    icon: Icon(
                      Icons.shuffle_rounded,
                      color: playerState.isShuffleEnabled
                          ? AppColors.accentCoral
                          : AppColors.textLight.withValues(alpha: 0.6),
                      size: context.iconSize(20),
                    ),
                    tooltip: playerState.isShuffleEnabled
                        ? 'Shuffle: Active'
                        : 'Shuffle: Inactive',
                    onPressed: () {
                      context.read<AudioPlayerCubit>().toggleShuffle();
                    },
                  ),

                  // Repeat Mode Button
                  IconButton(
                    constraints: BoxConstraints(
                      minWidth: iconBtnSize,
                      minHeight: iconBtnSize,
                    ),
                    padding: const EdgeInsets.all(4),
                    icon: Icon(
                      playerState.repeatMode == AudioRepeatMode.once
                          ? Icons.repeat_one_rounded
                          : Icons.repeat_rounded,
                      color: playerState.repeatMode != AudioRepeatMode.off
                          ? AppColors.accentCoral
                          : AppColors.textLight.withValues(alpha: 0.6),
                      size: context.iconSize(20),
                    ),
                    tooltip: playerState.repeatMode.label,
                    onPressed: () {
                      context.read<AudioPlayerCubit>().cycleRepeatMode();
                    },
                  ),

                  // Selection Mode Toggle Button
                  IconButton(
                    constraints: BoxConstraints(
                      minWidth: iconBtnSize,
                      minHeight: iconBtnSize,
                    ),
                    padding: const EdgeInsets.all(4),
                    icon: Icon(
                      playerState.isSelectionMode
                          ? Icons.edit_off_rounded
                          : Icons.checklist_rounded,
                      color: playerState.isSelectionMode
                          ? AppColors.accentCoral
                          : AppColors.textLight.withValues(alpha: 0.8),
                      size: context.iconSize(20),
                    ),
                    tooltip: playerState.isSelectionMode
                        ? 'Exit Selection Mode'
                        : 'Select Multiple',
                    onPressed: () {
                      context.read<AudioPlayerCubit>().toggleSelectionMode();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllTracksTabContent(
    BuildContext context,
    AudioPlayerState playerState,
    FavoritesState favState,
    double horizontalPadding,
  ) {
    if (playerState.isLoadingTracks && playerState.tracks.isEmpty) {
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

    if (playerState.tracks.isEmpty) {
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
                'No audio tracks found',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textLight,
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.h(0.008).clamp(4.0, 10.0)),
              Text(
                'Grant storage permissions or transfer audio files to your device.',
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
        itemCount: playerState.tracks.length,
        separatorBuilder: (_, index) =>
            SizedBox(height: context.h(0.012).clamp(6.0, 14.0)),
        itemBuilder: (context, index) {
          final track = playerState.tracks[index];
          final isCurrentPlaying = playerState.currentTrack?.id == track.id;
          final isFavorite = favState.isFavorite(track.id);
          final isSelected = playerState.isTrackSelected(track.id);

          return _TrackItemRow(
            track: track,
            isPlaying: isCurrentPlaying,
            isFavorite: isFavorite,
            isSelected: isSelected,
            isSelectionMode: playerState.isSelectionMode,
            onTap: () {
              if (playerState.isSelectionMode) {
                context.read<AudioPlayerCubit>().toggleSelect(track.id);
              } else {
                context.read<AudioPlayerCubit>().playTrack(track);
              }
            },
            onToggleSelect: () {
              context.read<AudioPlayerCubit>().toggleSelect(track.id);
            },
            onToggleFavorite: () {
              context.read<FavoritesCubit>().toggleFavorite(track);
            },
            onDelete: () {
              _confirmSingleDelete(context, track);
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoritesTabContent(
    BuildContext context,
    AudioPlayerState playerState,
    FavoritesState favState,
    double horizontalPadding,
  ) {
    if (favState.favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding * 1.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: context.iconSize(60),
                color: AppColors.accentCoral.withValues(alpha: 0.6),
              ),
              SizedBox(height: context.h(0.015).clamp(8.0, 16.0)),
              Text(
                'No favorites yet',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textLight,
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.h(0.008).clamp(4.0, 10.0)),
              Text(
                'Tap the heart icon on any audio track to save it to your local favorites database.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: context.sp(12),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: context.h(0.01).clamp(6.0, 14.0),
      ),
      itemCount: favState.favorites.length,
      separatorBuilder: (_, index) =>
          SizedBox(height: context.h(0.012).clamp(6.0, 14.0)),
      itemBuilder: (context, index) {
        final fav = favState.favorites[index];
        final track = Track(
          id: fav.trackId,
          title: fav.title,
          artist: fav.artist,
          album: fav.album,
          duration: fav.duration,
          audioUrl: fav.audioUrl,
        );
        final isCurrentPlaying = playerState.currentTrack?.id == track.id;

        return _TrackItemRow(
          track: track,
          isPlaying: isCurrentPlaying,
          isFavorite: true,
          isSelected: false,
          isSelectionMode: false,
          onTap: () {
            context.read<AudioPlayerCubit>().playTrack(track);
          },
          onToggleSelect: () {},
          onToggleFavorite: () {
            context.read<FavoritesCubit>().removeFavorite(track.id);
          },
          onDelete: () {
            _confirmSingleDelete(context, track);
          },
        );
      },
    );
  }

  Future<void> _confirmSingleDelete(BuildContext context, Track track) async {
    final confirmed = await _showConfirmationDialog(
      context: context,
      title: 'Remove Track',
      message:
          'Are you sure you want to remove "${track.title}" from this playlist? The audio file will not be deleted from your device.',
      confirmLabel: 'REMOVE',
    );

    if (confirmed == true && context.mounted) {
      await context.read<AudioPlayerCubit>().removeTrack(track.id);
    }
  }

  Future<void> _confirmBatchDelete(BuildContext context, int count) async {
    final confirmed = await _showConfirmationDialog(
      context: context,
      title: 'Remove Multiple Tracks',
      message:
          'Are you sure you want to remove $count tracks from this playlist? The audio files will not be deleted from your device.',
      confirmLabel: 'REMOVE ALL ($count)',
    );

    if (confirmed == true && context.mounted) {
      await context.read<AudioPlayerCubit>().removeSelectedTracks();
    }
  }

  Future<bool?> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.accentCoral,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: AppColors.textLight.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentCoral,
                foregroundColor: AppColors.textLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                confirmLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterTabPill extends StatelessWidget {
  const _FilterTabPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(0.025).clamp(8.0, 14.0),
          vertical: context.h(0.006).clamp(3.0, 6.0),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentCoral : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.textLight
                : AppColors.textLight.withValues(alpha: 0.7),
            fontSize: context.sp(11),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
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
    required this.isFavorite,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onToggleSelect,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  final Track track;
  final bool isPlaying;
  final bool isFavorite;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onToggleSelect;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final rowHeight = context.h(0.064).clamp(48.0, 60.0);
    final checkCircleSize = context.iconSize(24);

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
            // Selection Checkbox circle
            GestureDetector(
              onTap: onToggleSelect,
              child: Container(
                width: checkCircleSize,
                height: checkCircleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.accentCoral
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentCoral
                        : AppColors.textLight.withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: context.iconSize(16),
                        color: AppColors.textLight,
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
                isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                color: isFavorite ? AppColors.accentCoral : AppColors.textLight,
                size: context.iconSize(20),
              ),
              tooltip: isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              onPressed: onToggleFavorite,
            ),

            // Single Delete Icon (Cart completely removed!)
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textLight.withValues(alpha: 0.8),
                size: context.iconSize(20),
              ),
              tooltip: 'Remove from playlist',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
