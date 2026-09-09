import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/application/player.dart';
import 'package:media_player/domain/player.dart';

enum AudioPlayerStatus { initial, loading, playing, paused, completed, error }

enum AudioPermissionStatus {
  initial,
  checking,
  granted,
  denied,
  permanentlyDenied,
}

class AudioPlayerState extends Equatable {
  const AudioPlayerState({
    this.status = AudioPlayerStatus.initial,
    this.permissionStatus = AudioPermissionStatus.initial,
    this.errorMessage,
    this.isLoadingTracks = false,
    this.hasScannedDevice = false,
    this.currentTrack,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.tracks = const [],
    this.playlists = const [],
    this.selectedPlaylist,
    this.repeatMode = AudioRepeatMode.off,
    this.isShuffleEnabled = false,
    this.isSelectionMode = false,
    this.selectedTrackIds = const {},
    this.highlightedTrackId,
    this.initialScrollIndex,
    this.hasRestoredSession = false,
  });

  final AudioPlayerStatus status;
  final AudioPermissionStatus permissionStatus;
  final String? errorMessage;
  final bool isLoadingTracks;
  final bool hasScannedDevice;
  final Track? currentTrack;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final List<Track> tracks;
  final List<Playlist> playlists;
  final Playlist? selectedPlaylist;
  final AudioRepeatMode repeatMode;
  final bool isShuffleEnabled;
  final bool isSelectionMode;
  final Set<String> selectedTrackIds;
  final String? highlightedTrackId;
  final int? initialScrollIndex;
  final bool hasRestoredSession;

  bool isTrackSelected(String trackId) => selectedTrackIds.contains(trackId);

  String get formattedPosition {
    final minutes = position.inMinutes;
    final seconds = (position.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get progressNormalized {
    if (duration.inMilliseconds == 0) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  AudioPlayerState copyWith({
    AudioPlayerStatus? status,
    AudioPermissionStatus? permissionStatus,
    String? errorMessage,
    bool? isLoadingTracks,
    bool? hasScannedDevice,
    Track? currentTrack,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    List<Track>? tracks,
    List<Playlist>? playlists,
    Playlist? selectedPlaylist,
    AudioRepeatMode? repeatMode,
    bool? isShuffleEnabled,
    bool? isSelectionMode,
    Set<String>? selectedTrackIds,
    String? highlightedTrackId,
    int? initialScrollIndex,
    bool? hasRestoredSession,
    bool clearError = false,
    bool clearHighlightedTrack = false,
    bool clearInitialScroll = false,
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoadingTracks: isLoadingTracks ?? this.isLoadingTracks,
      hasScannedDevice: hasScannedDevice ?? this.hasScannedDevice,
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      tracks: tracks ?? this.tracks,
      playlists: playlists ?? this.playlists,
      selectedPlaylist: selectedPlaylist ?? this.selectedPlaylist,
      repeatMode: repeatMode ?? this.repeatMode,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedTrackIds: selectedTrackIds ?? this.selectedTrackIds,
      highlightedTrackId: clearHighlightedTrack
          ? null
          : (highlightedTrackId ?? this.highlightedTrackId),
      initialScrollIndex: clearInitialScroll
          ? null
          : (initialScrollIndex ?? this.initialScrollIndex),
      hasRestoredSession: hasRestoredSession ?? this.hasRestoredSession,
    );
  }

  @override
  List<Object?> get props => [
    status,
    permissionStatus,
    errorMessage,
    isLoadingTracks,
    hasScannedDevice,
    currentTrack,
    isPlaying,
    position,
    duration,
    tracks,
    playlists,
    selectedPlaylist,
    repeatMode,
    isShuffleEnabled,
    isSelectionMode,
    selectedTrackIds,
    highlightedTrackId,
    initialScrollIndex,
    hasRestoredSession,
  ];
}

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  AudioPlayerCubit({
    required this.audioPlayerRepository,
    required this.playTrackUseCase,
    required this.pauseTrackUseCase,
    required this.resumeTrackUseCase,
    required this.seekTrackUseCase,
    required this.nextTrackUseCase,
    required this.previousTrackUseCase,
    required this.getPlaylistsUseCase,
    required this.getTracksUseCase,
    required this.toggleFavoriteUseCase,
    required this.toggleSelectUseCase,
    this.preferencesRepository,
    CheckAudioPermissionsUseCase? checkAudioPermissionsUseCase,
    RequestAudioPermissionsUseCase? requestAudioPermissionsUseCase,
    ScanLocalTracksUseCase? scanLocalTracksUseCase,
    RemoveTrackUseCase? removeTrackUseCase,
    RemoveTracksUseCase? removeTracksUseCase,
    SetRepeatModeUseCase? setRepeatModeUseCase,
    SetShuffleModeUseCase? setShuffleModeUseCase,
  }) : checkAudioPermissionsUseCase =
           checkAudioPermissionsUseCase ??
           CheckAudioPermissionsUseCase(audioPlayerRepository),
       requestAudioPermissionsUseCase =
           requestAudioPermissionsUseCase ??
           RequestAudioPermissionsUseCase(audioPlayerRepository),
       scanLocalTracksUseCase =
           scanLocalTracksUseCase ??
           ScanLocalTracksUseCase(audioPlayerRepository),
       removeTrackUseCase =
           removeTrackUseCase ?? RemoveTrackUseCase(audioPlayerRepository),
       removeTracksUseCase =
           removeTracksUseCase ?? RemoveTracksUseCase(audioPlayerRepository),
       setRepeatModeUseCase =
           setRepeatModeUseCase ?? SetRepeatModeUseCase(audioPlayerRepository),
       setShuffleModeUseCase =
           setShuffleModeUseCase ??
           SetShuffleModeUseCase(audioPlayerRepository),
       super(const AudioPlayerState()) {
    _initSubscriptions();
  }

  final AudioPlayerRepository audioPlayerRepository;
  final PlayTrackUseCase playTrackUseCase;
  final PauseTrackUseCase pauseTrackUseCase;
  final ResumeTrackUseCase resumeTrackUseCase;
  final SeekTrackUseCase seekTrackUseCase;
  final NextTrackUseCase nextTrackUseCase;
  final PreviousTrackUseCase previousTrackUseCase;
  final GetPlaylistsUseCase getPlaylistsUseCase;
  final GetTracksUseCase getTracksUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final ToggleSelectUseCase toggleSelectUseCase;
  final PlayerPreferencesRepository? preferencesRepository;
  final CheckAudioPermissionsUseCase checkAudioPermissionsUseCase;
  final RequestAudioPermissionsUseCase requestAudioPermissionsUseCase;
  final ScanLocalTracksUseCase scanLocalTracksUseCase;
  final RemoveTrackUseCase removeTrackUseCase;
  final RemoveTracksUseCase removeTracksUseCase;
  final SetRepeatModeUseCase setRepeatModeUseCase;
  final SetShuffleModeUseCase setShuffleModeUseCase;

  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Track?>? _trackSub;
  StreamSubscription<String?>? _errorSub;
  StreamSubscription<AudioRepeatMode>? _repeatModeSub;

  void _initSubscriptions() {
    _playingSub = audioPlayerRepository.isPlayingStream.listen((playing) {
      emit(
        state.copyWith(
          isPlaying: playing,
          status: playing
              ? AudioPlayerStatus.playing
              : AudioPlayerStatus.paused,
        ),
      );
    });

    _positionSub = audioPlayerRepository.positionStream.listen((pos) {
      emit(state.copyWith(position: pos));
    });

    _durationSub = audioPlayerRepository.durationStream.listen((dur) {
      emit(state.copyWith(duration: dur));
    });

    _trackSub = audioPlayerRepository.currentTrackStream.listen((track) {
      emit(
        state.copyWith(
          currentTrack: track,
          highlightedTrackId: track?.id ?? state.highlightedTrackId,
        ),
      );
    });

    _repeatModeSub = audioPlayerRepository.repeatModeStream.listen((mode) {
      emit(state.copyWith(repeatMode: mode));
    });

    _errorSub = audioPlayerRepository.playbackErrorStream.listen((error) {
      if (error != null) {
        emit(
          state.copyWith(
            status: AudioPlayerStatus.error,
            errorMessage: error,
            isPlaying: false,
          ),
        );
      }
    });

    loadInitialData();
  }

  Future<void> loadInitialData() async {
    // 1. Load persisted preferences safely
    var savedRepeat = AudioRepeatMode.off;
    var savedShuffle = false;
    LastSessionContext? lastSession;

    if (preferencesRepository != null) {
      try {
        savedRepeat = await preferencesRepository!.getRepeatMode();
        savedShuffle = await preferencesRepository!.isShuffleEnabled();
        lastSession = await preferencesRepository!.getLastTrack();
      } catch (e) {
        debugPrint('AudioPlayerCubit: Failed loading preferences: $e');
      }
    }

    // 2. Sync underlying audio player repository
    unawaited(audioPlayerRepository.setRepeatMode(savedRepeat));
    unawaited(audioPlayerRepository.setShuffle(savedShuffle));

    final playlists = await getPlaylistsUseCase.execute();
    final hasPermission = await checkAudioPermissionsUseCase.execute();

    List<Track> loadedTracks;
    if (hasPermission) {
      emit(
        state.copyWith(
          permissionStatus: AudioPermissionStatus.granted,
          isLoadingTracks: true,
          playlists: playlists,
          selectedPlaylist: playlists.isNotEmpty ? playlists.first : null,
          repeatMode: savedRepeat,
          isShuffleEnabled: savedShuffle,
        ),
      );
      loadedTracks = await scanLocalTracksUseCase.execute();
    } else {
      loadedTracks = await getTracksUseCase.execute();
      emit(
        state.copyWith(
          permissionStatus: AudioPermissionStatus.denied,
          tracks: loadedTracks,
          playlists: playlists,
          selectedPlaylist: playlists.isNotEmpty ? playlists.first : null,
          repeatMode: savedRepeat,
          isShuffleEnabled: savedShuffle,
        ),
      );
    }

    // 3. Reconstruct session track context without auto-playing
    Track? restoredTrack;
    int? restoredScrollIndex;
    String? restoredHighlightedId;
    var restoredPosition = Duration.zero;
    var restoredDuration = Duration.zero;

    if (lastSession != null) {
      final matchedIndex = loadedTracks.indexWhere(
        (t) => t.id == lastSession!.trackId,
      );
      if (matchedIndex != -1) {
        restoredTrack = loadedTracks[matchedIndex];
        restoredScrollIndex = matchedIndex;
      } else {
        restoredTrack = Track(
          id: lastSession.trackId,
          title: lastSession.title,
          artist: lastSession.artist,
          album: lastSession.album,
          duration: lastSession.duration,
          audioUrl: lastSession.audioUrl,
        );
        restoredScrollIndex = lastSession.index.clamp(
          0,
          loadedTracks.isNotEmpty ? loadedTracks.length - 1 : 0,
        );
      }
      restoredHighlightedId = restoredTrack.id;
      restoredPosition = lastSession.position;
      restoredDuration = restoredTrack.duration;
    } else if (loadedTracks.isNotEmpty) {
      restoredTrack = loadedTracks.first;
      restoredScrollIndex = 0;
      restoredDuration = restoredTrack.duration;
      restoredHighlightedId = restoredTrack.id;
    }

    emit(
      state.copyWith(
        tracks: loadedTracks,
        isLoadingTracks: false,
        hasScannedDevice: hasPermission,
        currentTrack: state.currentTrack ?? restoredTrack,
        position: restoredPosition,
        duration: restoredDuration,
        repeatMode: savedRepeat,
        isShuffleEnabled: savedShuffle,
        highlightedTrackId: restoredHighlightedId,
        initialScrollIndex: restoredScrollIndex,
        hasRestoredSession: true,
        isPlaying: false,
        status: AudioPlayerStatus.paused,
      ),
    );
  }

  Future<void> requestPermissionsAndScan() async {
    emit(
      state.copyWith(
        isLoadingTracks: true,
        permissionStatus: AudioPermissionStatus.checking,
        clearError: true,
      ),
    );

    final granted = await requestAudioPermissionsUseCase.execute();
    if (granted) {
      final localTracks = await scanLocalTracksUseCase.execute();
      Track? current = state.currentTrack;
      if (current == null && localTracks.isNotEmpty) {
        current = localTracks.first;
      }
      emit(
        state.copyWith(
          permissionStatus: AudioPermissionStatus.granted,
          tracks: localTracks,
          isLoadingTracks: false,
          hasScannedDevice: true,
          currentTrack: current,
        ),
      );
    } else {
      emit(
        state.copyWith(
          permissionStatus: AudioPermissionStatus.denied,
          isLoadingTracks: false,
          hasScannedDevice: true,
          errorMessage: 'Storage/Audio permission denied. Please grant permission in settings to access local audio files.',
        ),
      );
    }
  }

  Future<void> refreshLibrary() async {
    emit(state.copyWith(isLoadingTracks: true, clearError: true));
    try {
      final updatedTracks = await scanLocalTracksUseCase.execute();
      emit(
        state.copyWith(
          tracks: updatedTracks,
          isLoadingTracks: false,
          hasScannedDevice: true,
          currentTrack:
              state.currentTrack ??
              (updatedTracks.isNotEmpty ? updatedTracks.first : null),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingTracks: false,
          errorMessage: 'Failed to refresh audio tracks: $e',
        ),
      );
    }
  }

  Future<void> playTrack(Track track) async {
    final trackIndex = state.tracks.indexWhere((t) => t.id == track.id);
    final idx = trackIndex >= 0 ? trackIndex : 0;

    // Persist immediately
    if (preferencesRepository != null) {
      unawaited(
        preferencesRepository!.saveLastTrack(track, idx, Duration.zero),
      );
    }

    emit(
      state.copyWith(
        status: AudioPlayerStatus.loading,
        currentTrack: track,
        highlightedTrackId: track.id,
        clearError: true,
      ),
    );

    try {
      await playTrackUseCase.execute(track);
      emit(
        state.copyWith(
          isPlaying: true,
          status: AudioPlayerStatus.playing,
          currentTrack: track,
          highlightedTrackId: track.id,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: 'Error playing "${track.title}": $e',
          isPlaying: false,
        ),
      );
    }
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pauseTrackUseCase.execute();
      emit(state.copyWith(isPlaying: false, status: AudioPlayerStatus.paused));

      // Persist current track & playback position upon pause
      if (state.currentTrack != null && preferencesRepository != null) {
        final idx = state.tracks.indexWhere(
          (t) => t.id == state.currentTrack!.id,
        );
        unawaited(
          preferencesRepository!.saveLastTrack(
            state.currentTrack!,
            idx >= 0 ? idx : 0,
            state.position,
          ),
        );
      }
    } else {
      await resumeTrackUseCase.execute();
      emit(state.copyWith(isPlaying: true, status: AudioPlayerStatus.playing));
    }
  }

  Future<void> seek(Duration position) async {
    await seekTrackUseCase.execute(position);
    emit(state.copyWith(position: position));

    if (state.currentTrack != null && preferencesRepository != null) {
      final idx = state.tracks.indexWhere(
        (t) => t.id == state.currentTrack!.id,
      );
      unawaited(
        preferencesRepository!.saveLastTrack(
          state.currentTrack!,
          idx >= 0 ? idx : 0,
          position,
        ),
      );
    }
  }

  Future<void> next() async {
    await nextTrackUseCase.execute();
  }

  Future<void> previous() async {
    await previousTrackUseCase.execute();
  }

  Future<void> toggleFavorite(String trackId) async {
    await toggleFavoriteUseCase.execute(trackId);
    final updatedTracks = await getTracksUseCase.execute();
    emit(state.copyWith(tracks: updatedTracks));
  }

  Future<void> cycleRepeatMode() async {
    final nextMode = state.repeatMode.next;
    await setRepeatModeUseCase.execute(nextMode);
    emit(state.copyWith(repeatMode: nextMode));
    if (preferencesRepository != null) {
      unawaited(preferencesRepository!.saveRepeatMode(nextMode));
    }
  }

  Future<void> setRepeatMode(AudioRepeatMode mode) async {
    await setRepeatModeUseCase.execute(mode);
    emit(state.copyWith(repeatMode: mode));
    if (preferencesRepository != null) {
      unawaited(preferencesRepository!.saveRepeatMode(mode));
    }
  }

  Future<void> toggleShuffle() async {
    final newShuffle = !state.isShuffleEnabled;
    await setShuffleModeUseCase.execute(newShuffle);
    emit(state.copyWith(isShuffleEnabled: newShuffle));
    if (preferencesRepository != null) {
      unawaited(preferencesRepository!.saveShuffleEnabled(newShuffle));
    }
  }

  Future<void> saveSessionSnapshot() async {
    if (state.currentTrack != null && preferencesRepository != null) {
      final idx = state.tracks.indexWhere(
        (t) => t.id == state.currentTrack!.id,
      );
      await preferencesRepository!.saveLastTrack(
        state.currentTrack!,
        idx >= 0 ? idx : 0,
        state.position,
      );
    }
  }

  void clearInitialScroll() {
    emit(state.copyWith(clearInitialScroll: true));
  }

  Future<void> removeTrack(
    String trackId, {
    bool deleteFromDevice = false,
  }) async {
    await removeTrackUseCase.execute(
      trackId,
      deleteFromDevice: deleteFromDevice,
    );
    final updatedTracks = await getTracksUseCase.execute();
    final updatedSelected = Set<String>.from(state.selectedTrackIds)
      ..remove(trackId);
    Track? current = state.currentTrack;
    if (current?.id == trackId) {
      current = updatedTracks.isNotEmpty ? updatedTracks.first : null;
    }
    emit(
      state.copyWith(
        tracks: updatedTracks,
        selectedTrackIds: updatedSelected,
        isSelectionMode: updatedSelected.isNotEmpty,
        currentTrack: current,
      ),
    );
  }

  Future<void> removeSelectedTracks({bool deleteFromDevice = false}) async {
    if (state.selectedTrackIds.isEmpty) return;
    await removeTracksUseCase.execute(
      state.selectedTrackIds.toList(),
      deleteFromDevice: deleteFromDevice,
    );
    final updatedTracks = await getTracksUseCase.execute();
    Track? current = state.currentTrack;
    if (current != null && state.selectedTrackIds.contains(current.id)) {
      current = updatedTracks.isNotEmpty ? updatedTracks.first : null;
    }
    emit(
      state.copyWith(
        tracks: updatedTracks,
        selectedTrackIds: const {},
        isSelectionMode: false,
        currentTrack: current,
      ),
    );
  }

  void toggleSelectionMode([bool? enabled]) {
    final newMode = enabled ?? !state.isSelectionMode;
    emit(
      state.copyWith(
        isSelectionMode: newMode,
        selectedTrackIds: newMode ? state.selectedTrackIds : const {},
      ),
    );
  }

  void selectAllTracks() {
    emit(
      state.copyWith(
        selectedTrackIds: state.tracks.map((t) => t.id).toSet(),
        isSelectionMode: true,
      ),
    );
  }

  void clearSelection() {
    emit(state.copyWith(selectedTrackIds: const {}, isSelectionMode: false));
  }

  Future<void> toggleSelect(String trackId) async {
    final newSelected = Set<String>.from(state.selectedTrackIds);
    if (newSelected.contains(trackId)) {
      newSelected.remove(trackId);
    } else {
      newSelected.add(trackId);
    }
    await toggleSelectUseCase.execute(trackId);
    final updatedTracks = await getTracksUseCase.execute();
    emit(
      state.copyWith(
        tracks: updatedTracks,
        selectedTrackIds: newSelected,
        isSelectionMode: newSelected.isNotEmpty,
      ),
    );
  }

  void selectPlaylist(Playlist playlist) {
    emit(state.copyWith(selectedPlaylist: playlist));
  }

  void dismissError() {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    _playingSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _trackSub?.cancel();
    _errorSub?.cancel();
    _repeatModeSub?.cancel();
    return super.close();
  }
}
