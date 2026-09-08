import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/application/player.dart';
import 'package:media_player/domain/player.dart';

class AudioPlayerState extends Equatable {
  const AudioPlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.position = const Duration(minutes: 1, seconds: 24),
    this.duration = const Duration(minutes: 2, seconds: 40),
    this.tracks = const [],
    this.playlists = const [],
    this.selectedPlaylist,
  });

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
    Track? currentTrack,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    List<Track>? tracks,
    List<Playlist>? playlists,
    Playlist? selectedPlaylist,
  }) {
    return AudioPlayerState(
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
  }) : super(const AudioPlayerState()) {
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

  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Track?>? _trackSub;

  void _initSubscriptions() {
    _playingSub = audioPlayerRepository.isPlayingStream.listen((playing) {
      emit(state.copyWith(isPlaying: playing));
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

    loadInitialData();
  }

  Future<void> loadInitialData() async {
    final tracks = await getTracksUseCase.execute();
    final playlists = await getPlaylistsUseCase.execute();
    emit(
      state.copyWith(
        tracks: tracks,
        playlists: playlists,
        currentTrack:
            state.currentTrack ?? (tracks.isNotEmpty ? tracks.first : null),
        selectedPlaylist: playlists.isNotEmpty ? playlists.first : null,
      ),
    );
  }

  Future<void> playTrack(Track track) async {
    await playTrackUseCase.execute(track);
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pauseTrackUseCase.execute();
    } else {
      await resumeTrackUseCase.execute();
    }
  }

  Future<void> seek(Duration position) async {
    await seekTrackUseCase.execute(position);
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

  @override
  Future<void> close() {
    _playingSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _trackSub?.cancel();
    return super.close();
  }
}
