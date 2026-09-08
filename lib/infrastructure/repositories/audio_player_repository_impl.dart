import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:media_player/domain/entities/playlist.dart';
import 'package:media_player/domain/entities/track.dart';
import 'package:media_player/domain/repositories/audio_player_repository.dart';
import 'package:media_player/infrastructure/datasources/local_audio_data_source.dart';
import 'package:media_player/infrastructure/datasources/music_mock_data_source.dart';

class AudioPlayerRepositoryImpl implements AudioPlayerRepository {
  AudioPlayerRepositoryImpl({
    AudioPlayer? player,
    LocalAudioDataSource? localAudioDataSource,
  }) : _player = player ?? AudioPlayer(),
       _localAudioDataSource =
           localAudioDataSource ?? LocalAudioDataSourceImpl() {
    _tracks = List<Track>.from(MusicMockDataSource.defaultTracks);
    _playlists = List<Playlist>.from(MusicMockDataSource.defaultPlaylists);
    _currentTrack = _tracks.isNotEmpty ? _tracks.first : null;

    _initPlayerListeners();
  }

  final AudioPlayer _player;
  final LocalAudioDataSource _localAudioDataSource;

  late List<Track> _tracks;
  late final List<Playlist> _playlists;
  Track? _currentTrack;
  bool _isPlaying = false;

  final _isPlayingController = StreamController<bool>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _currentTrackController = StreamController<Track?>.broadcast();
  final _playbackErrorController = StreamController<String?>.broadcast();

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlaybackEvent>? _playbackEventSub;

  void _initPlayerListeners() {
    try {
      _playerStateSub = _player.playerStateStream.listen(
        (playerState) {
          _isPlaying = playerState.playing;
          _isPlayingController.add(_isPlaying);

          // Continuous playback logic: auto-play next track when completed
          if (playerState.processingState == ProcessingState.completed) {
            next();
          }
        },
        onError: (Object error) {
          debugPrint('AudioPlayer playerStateStream error: $error');
          _playbackErrorController.add('Playback state error: $error');
        },
      );

      _positionSub = _player.positionStream.listen(
        (pos) {
          _positionController.add(pos);
        },
        onError: (Object error) {
          debugPrint('AudioPlayer positionStream error: $error');
        },
      );

      _durationSub = _player.durationStream.listen(
        (dur) {
          if (dur != null) {
            _durationController.add(dur);
          }
        },
        onError: (Object error) {
          debugPrint('AudioPlayer durationStream error: $error');
        },
      );

      _playbackEventSub = _player.playbackEventStream.listen(
        (_) {},
        onError: (Object error) {
          debugPrint('AudioPlayer playbackEventStream error: $error');
          _playbackErrorController.add('Audio playback error: $error');
        },
      );
    } catch (e) {
      debugPrint('Error initializing AudioPlayer stream subscriptions: $e');
    }
  }

  @override
  Stream<bool> get isPlayingStream => _isPlayingController.stream;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration> get durationStream => _durationController.stream;

  @override
  Stream<Track?> get currentTrackStream => _currentTrackController.stream;

  @override
  Stream<String?> get playbackErrorStream => _playbackErrorController.stream;

  @override
  Future<void> play(Track track) async {
    _currentTrack = track;
    _currentTrackController.add(_currentTrack);

    if (track.duration > Duration.zero) {
      _durationController.add(track.duration);
    }

    try {
      if (track.audioUrl.isNotEmpty) {
        if (track.audioUrl.startsWith('content://')) {
          await _player.setAudioSource(
            AudioSource.uri(Uri.parse(track.audioUrl)),
          );
        } else if (track.audioUrl.startsWith('http://') ||
            track.audioUrl.startsWith('https://')) {
          await _player.setUrl(track.audioUrl);
        } else {
          await _player.setFilePath(track.audioUrl);
        }
        await _player.play();
      } else {
        // Track without URL (e.g. mock track in UI)
        _isPlaying = true;
        _isPlayingController.add(true);
      }
    } catch (e) {
      debugPrint('AudioPlayer play exception: $e');
      _playbackErrorController.add(
        'Unable to play "${track.title}": file may be corrupted or format is unsupported.',
      );
      _isPlaying = false;
      _isPlayingController.add(false);
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('AudioPlayer pause exception: $e');
    }
    _isPlaying = false;
    _isPlayingController.add(false);
  }

  @override
  Future<void> resume() async {
    try {
      if (_player.audioSource != null) {
        await _player.play();
      } else if (_currentTrack != null) {
        await play(_currentTrack!);
        return;
      }
    } catch (e) {
      debugPrint('AudioPlayer resume exception: $e');
    }
    _isPlaying = true;
    _isPlayingController.add(true);
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('AudioPlayer seek exception: $e');
    }
    _positionController.add(position);
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
              t.genre.toLowerCase().contains(q) ||
              t.album.toLowerCase().contains(q),
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

  @override
  Future<bool> checkPermissions() => _localAudioDataSource.checkPermissions();

  @override
  Future<bool> requestPermissions() =>
      _localAudioDataSource.requestPermissions();

  @override
  Future<List<Track>> scanLocalTracks() async {
    try {
      final localTracks = await _localAudioDataSource.queryTracks();
      if (localTracks.isNotEmpty) {
        _tracks = List<Track>.from(localTracks);
        if (_currentTrack == null ||
            !_tracks.any((t) => t.id == _currentTrack?.id)) {
          _currentTrack = _tracks.first;
          _currentTrackController.add(_currentTrack);
        }
      }
      return List.unmodifiable(_tracks);
    } catch (e) {
      debugPrint('AudioPlayerRepositoryImpl.scanLocalTracks exception: $e');
      return List.unmodifiable(_tracks);
    }
  }

  void dispose() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playbackEventSub?.cancel();
    _player.dispose();
    _isPlayingController.close();
    _positionController.close();
    _durationController.close();
    _currentTrackController.close();
    _playbackErrorController.close();
  }
}
