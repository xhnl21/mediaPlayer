import 'dart:async';

import 'package:equatable/equatable.dart';
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
    bool clearError = false,
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
    CheckAudioPermissionsUseCase? checkAudioPermissionsUseCase,
    RequestAudioPermissionsUseCase? requestAudioPermissionsUseCase,
    ScanLocalTracksUseCase? scanLocalTracksUseCase,
  }) : checkAudioPermissionsUseCase =
           checkAudioPermissionsUseCase ??
           CheckAudioPermissionsUseCase(audioPlayerRepository),
       requestAudioPermissionsUseCase =
           requestAudioPermissionsUseCase ??
           RequestAudioPermissionsUseCase(audioPlayerRepository),
       scanLocalTracksUseCase =
           scanLocalTracksUseCase ??
           ScanLocalTracksUseCase(audioPlayerRepository),
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
  final CheckAudioPermissionsUseCase checkAudioPermissionsUseCase;
  final RequestAudioPermissionsUseCase requestAudioPermissionsUseCase;
  final ScanLocalTracksUseCase scanLocalTracksUseCase;

  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Track?>? _trackSub;
  StreamSubscription<String?>? _errorSub;

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
      emit(state.copyWith(currentTrack: track));
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
    final playlists = await getPlaylistsUseCase.execute();
    final hasPermission = await checkAudioPermissionsUseCase.execute();

    if (hasPermission) {
      emit(
        state.copyWith(
          permissionStatus: AudioPermissionStatus.granted,
          isLoadingTracks: true,
          playlists: playlists,
          selectedPlaylist: playlists.isNotEmpty ? playlists.first : null,
        ),
      );
      final tracks = await scanLocalTracksUseCase.execute();
      emit(
        state.copyWith(
          tracks: tracks,
          isLoadingTracks: false,
          hasScannedDevice: true,
          currentTrack:
              state.currentTrack ?? (tracks.isNotEmpty ? tracks.first : null),
        ),
      );
    } else {
      final initialTracks = await getTracksUseCase.execute();
      emit(
        state.copyWith(
          permissionStatus: AudioPermissionStatus.denied,
          tracks: initialTracks,
          playlists: playlists,
          currentTrack:
              state.currentTrack ??
              (initialTracks.isNotEmpty ? initialTracks.first : null),
          selectedPlaylist: playlists.isNotEmpty ? playlists.first : null,
        ),
      );
    }
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
      emit(
        state.copyWith(
          permissionStatus: AudioPermissionStatus.granted,
          tracks: localTracks,
          isLoadingTracks: false,
          hasScannedDevice: true,
          currentTrack:
              state.currentTrack ??
              (localTracks.isNotEmpty ? localTracks.first : null),
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
    emit(
      state.copyWith(
        status: AudioPlayerStatus.loading,
        currentTrack: track,
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
    } else {
      await resumeTrackUseCase.execute();
      emit(state.copyWith(isPlaying: true, status: AudioPlayerStatus.playing));
    }
  }

  Future<void> seek(Duration position) async {
    await seekTrackUseCase.execute(position);
    emit(state.copyWith(position: position));
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

  Future<void> toggleSelect(String trackId) async {
    await toggleSelectUseCase.execute(trackId);
    final updatedTracks = await getTracksUseCase.execute();
    emit(state.copyWith(tracks: updatedTracks));
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
    return super.close();
  }
}
