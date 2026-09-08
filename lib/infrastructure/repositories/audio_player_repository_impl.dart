import 'dart:async';

import 'package:media_player/domain/entities/playlist.dart';
import 'package:media_player/domain/entities/track.dart';
import 'package:media_player/domain/repositories/audio_player_repository.dart';
import 'package:media_player/infrastructure/datasources/music_mock_data_source.dart';

class AudioPlayerRepositoryImpl implements AudioPlayerRepository {
  AudioPlayerRepositoryImpl() {
    _tracks = List<Track>.from(MusicMockDataSource.defaultTracks);
    _playlists = List<Playlist>.from(MusicMockDataSource.defaultPlaylists);
    _currentTrack = _tracks.isNotEmpty ? _tracks.first : null;
    _currentTrackController.add(_currentTrack);
    _durationController.add(
      _currentTrack?.duration ?? const Duration(minutes: 2, seconds: 40),
    );
    _positionController.add(
      const Duration(minutes: 1, seconds: 24),
    ); // Matches mockup 1:24
  }

  late final List<Track> _tracks;
  late final List<Playlist> _playlists;

  Track? _currentTrack;
  bool _isPlaying = false;
  Duration _position = const Duration(minutes: 1, seconds: 24);
  Timer? _playbackTimer;

  final _isPlayingController = StreamController<bool>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _currentTrackController = StreamController<Track?>.broadcast();

  @override
  Stream<bool> get isPlayingStream => _isPlayingController.stream;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration> get durationStream => _durationController.stream;

  @override
  Stream<Track?> get currentTrackStream => _currentTrackController.stream;

  @override
  Future<void> play(Track track) async {
    _currentTrack = track;
    _currentTrackController.add(_currentTrack);
    _durationController.add(track.duration);
    _isPlaying = true;
    _isPlayingController.add(true);
    _startTimer();
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
    _isPlayingController.add(false);
    _playbackTimer?.cancel();
  }

  @override
  Future<void> resume() async {
    _isPlaying = true;
    _isPlayingController.add(true);
    _startTimer();
  }

  @override
  Future<void> seek(Duration position) async {
    _position = position;
    _positionController.add(_position);
  }

  @override
  Future<void> next() async {
    if (_tracks.isEmpty) return;
    final currentIndex = _tracks.indexWhere((t) => t.id == _currentTrack?.id);
    final nextIndex = (currentIndex + 1) % _tracks.length;
    await play(_tracks[nextIndex]);
  }

  @override
  Future<void> previous() async {
    if (_tracks.isEmpty) return;
    final currentIndex = _tracks.indexWhere((t) => t.id == _currentTrack?.id);
    final prevIndex = (currentIndex - 1 + _tracks.length) % _tracks.length;
    await play(_tracks[prevIndex]);
  }

  @override
  Future<List<Playlist>> getPlaylists() async => List.unmodifiable(_playlists);

  @override
  Future<List<Track>> getTracks() async => List.unmodifiable(_tracks);

  @override
  Future<List<Track>> searchTracks(String query) async {
    if (query.trim().isEmpty) return List.unmodifiable(_tracks);
    final q = query.toLowerCase().trim();
    return _tracks
        .where(
          (t) =>
              t.title.toLowerCase().contains(q) ||
              t.artist.toLowerCase().contains(q) ||
              t.genre.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Future<void> toggleFavorite(String trackId) async {
    final index = _tracks.indexWhere((t) => t.id == trackId);
    if (index != -1) {
      _tracks[index] = _tracks[index].copyWith(
        isFavorite: !_tracks[index].isFavorite,
      );
      if (_currentTrack?.id == trackId) {
        _currentTrack = _tracks[index];
        _currentTrackController.add(_currentTrack);
      }
    }
  }

  @override
  Future<void> toggleSelect(String trackId) async {
    final index = _tracks.indexWhere((t) => t.id == trackId);
    if (index != -1) {
      _tracks[index] = _tracks[index].copyWith(
        isSelected: !_tracks[index].isSelected,
      );
    }
  }

  void _startTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      final maxDuration = _currentTrack?.duration ?? const Duration(minutes: 3);
      if (_position < maxDuration) {
        _position += const Duration(seconds: 1);
        _positionController.add(_position);
      } else {
        _position = Duration.zero;
        _positionController.add(_position);
        next();
      }
    });
  }

  void dispose() {
    _playbackTimer?.cancel();
    _isPlayingController.close();
    _positionController.close();
    _durationController.close();
    _currentTrackController.close();
  }
}
