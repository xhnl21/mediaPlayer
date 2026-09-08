import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:media_player/domain/entities/playlist.dart';
import 'package:media_player/domain/entities/repeat_mode.dart';
import 'package:media_player/domain/entities/track.dart';
import 'package:media_player/domain/repositories/audio_player_repository.dart';
import 'package:media_player/infrastructure/datasources/local_audio_data_source.dart';
import 'package:media_player/infrastructure/datasources/music_mock_data_source.dart';
import 'package:media_player/infrastructure/services/audio_player_handler.dart';

class AudioPlayerRepositoryImpl implements AudioPlayerRepository {
  AudioPlayerRepositoryImpl({
    AudioPlayer? player,
    AudioPlayerHandlerImpl? audioHandler,
    LocalAudioDataSource? localAudioDataSource,
    List<Track>? initialTracks,
  }) : _audioHandler = audioHandler,
       _player = audioHandler?.player ?? (player ?? AudioPlayer()),
       _localAudioDataSource =
           localAudioDataSource ?? LocalAudioDataSourceImpl() {
    _tracks = List<Track>.from(
      initialTracks ?? MusicMockDataSource.defaultTracks,
    );
    _playlists = List<Playlist>.from(MusicMockDataSource.defaultPlaylists);
    _currentTrack = _tracks.isNotEmpty ? _tracks.first : null;

    if (_audioHandler != null) {
      _audioHandler.onSkipToNextRequested = () => next();
      _audioHandler.onSkipToPreviousRequested = () => previous();
      _audioHandler.onTrackCompleted = () => _onTrackCompleted();
    }

    _initPlayerListeners();
  }

  final AudioPlayerHandlerImpl? _audioHandler;
  final AudioPlayer _player;
  final LocalAudioDataSource _localAudioDataSource;

  late List<Track> _tracks;
  late final List<Playlist> _playlists;
  Track? _currentTrack;
  bool _isPlaying = false;
  AudioRepeatMode _repeatMode = AudioRepeatMode.off;
  bool _isShuffle = false;
  final List<String> _shuffledOrder = [];
  int _shuffledIndex = 0;

  final _isPlayingController = StreamController<bool>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _currentTrackController = StreamController<Track?>.broadcast();
  final _playbackErrorController = StreamController<String?>.broadcast();
  final _repeatModeController = StreamController<AudioRepeatMode>.broadcast();

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

          // Continuous playback logic: handle repeat modes and shuffle on track completion
          if (playerState.processingState == ProcessingState.completed) {
            _onTrackCompleted();
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
  Stream<AudioRepeatMode> get repeatModeStream => _repeatModeController.stream;

  Track? get currentTrack => _currentTrack;

  @override
  Future<void> play(Track track) async {
    _currentTrack = track;
    _currentTrackController.add(_currentTrack);

    if (track.duration > Duration.zero) {
      _durationController.add(track.duration);
    }

    try {
      if (_audioHandler != null) {
        await _audioHandler.playTrack(track);
      } else if (track.audioUrl.isNotEmpty) {
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
        // Ensure loop mode is set on the native audio player
        await _player.setLoopMode(
          _repeatMode == AudioRepeatMode.all ? LoopMode.one : LoopMode.off,
        );
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
      if (_audioHandler != null) {
        await _audioHandler.pause();
      } else {
        await _player.pause();
      }
    } catch (e) {
      debugPrint('AudioPlayer pause exception: $e');
    }
    _isPlaying = false;
    _isPlayingController.add(false);
  }

  @override
  Future<void> resume() async {
    try {
      if (_audioHandler != null) {
        await _audioHandler.play();
      } else if (_player.audioSource != null) {
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
      if (_audioHandler != null) {
        await _audioHandler.seek(position);
      } else {
        await _player.seek(position);
      }
    } catch (e) {
      debugPrint('AudioPlayer seek exception: $e');
    }
    _positionController.add(position);
  }

  @override
  Future<void> setRepeatMode(AudioRepeatMode mode) async {
    _repeatMode = mode;
    _repeatModeController.add(_repeatMode);
    try {
      if (_audioHandler != null) {
        await _audioHandler.setAudioRepeatMode(mode);
      } else {
        // AudioRepeatMode.all loops the current audio indefinitely via just_audio's native LoopMode.one
        if (mode == AudioRepeatMode.all) {
          await _player.setLoopMode(LoopMode.one);
        } else {
          await _player.setLoopMode(LoopMode.off);
        }
      }
    } catch (e) {
      debugPrint('AudioPlayer setLoopMode exception: $e');
    }
  }

  @override
  Future<void> setShuffle(bool enabled) async {
    _isShuffle = enabled;
    _audioHandler?.setShuffle(enabled);
    if (_isShuffle) {
      _rebuildShuffleQueue();
    }
  }

  void _rebuildShuffleQueue() {
    _shuffledOrder.clear();
    final ids = _tracks.map((t) => t.id).toList()..shuffle();
    if (_currentTrack != null) {
      ids.remove(_currentTrack!.id);
      ids.insert(0, _currentTrack!.id);
    }
    _shuffledOrder.addAll(ids);
    _shuffledIndex = 0;
  }

  void _onTrackCompleted() async {
    if (_tracks.isEmpty) return;

    // 1. Repeat current track once: replay and revert to off
    if (_repeatMode == AudioRepeatMode.once) {
      _repeatMode = AudioRepeatMode.off;
      _repeatModeController.add(AudioRepeatMode.off);
      await _audioHandler?.setAudioRepeatMode(AudioRepeatMode.off);
      try {
        await _player.seek(Duration.zero);
        await _player.play();
      } catch (e) {
        debugPrint('AudioPlayer repeat once exception: $e');
        if (_currentTrack != null) {
          await play(_currentTrack!);
        }
      }
      return;
    }

    // 2. Repeat current track indefinitely in a loop
    if (_repeatMode == AudioRepeatMode.all) {
      try {
        await _player.seek(Duration.zero);
        await _player.play();
      } catch (e) {
        debugPrint('AudioPlayer repeat loop exception: $e');
        if (_currentTrack != null) {
          await play(_currentTrack!);
        }
      }
      return;
    }

    // 3. Normal / Shuffle progression
    if (_isShuffle) {
      await _nextShuffled();
    } else {
      final currentIndex = _tracks.indexWhere((t) => t.id == _currentTrack?.id);
      if (currentIndex == -1) {
        if (_tracks.isNotEmpty) await play(_tracks.first);
        return;
      }
      final isLast = currentIndex >= _tracks.length - 1;
      if (isLast && _repeatMode == AudioRepeatMode.off) {
        await pause();
        await seek(Duration.zero);
      } else {
        final nextIndex = (currentIndex + 1) % _tracks.length;
        await play(_tracks[nextIndex]);
      }
    }
  }

  @override
  Future<void> next() async {
    if (_tracks.isEmpty) return;
    if (_isShuffle) {
      await _nextShuffled();
    } else {
      final currentIndex = _tracks.indexWhere((t) => t.id == _currentTrack?.id);
      final nextIndex = (currentIndex + 1) % _tracks.length;
      await play(_tracks[nextIndex]);
    }
  }

  Future<void> _nextShuffled() async {
    if (_tracks.isEmpty) return;
    if (_shuffledOrder.isEmpty || _shuffledIndex >= _shuffledOrder.length - 1) {
      _rebuildShuffleQueue();
    } else {
      _shuffledIndex++;
    }
    final nextId = _shuffledOrder.isNotEmpty
        ? _shuffledOrder[_shuffledIndex]
        : null;
    final nextTrack = _tracks.firstWhere(
      (t) => t.id == nextId,
      orElse: () => _tracks.first,
    );
    await play(nextTrack);
  }

  @override
  Future<void> previous() async {
    if (_tracks.isEmpty) return;
    if (_isShuffle) {
      if (_shuffledOrder.isNotEmpty && _shuffledIndex > 0) {
        _shuffledIndex--;
        final prevId = _shuffledOrder[_shuffledIndex];
        final prevTrack = _tracks.firstWhere(
          (t) => t.id == prevId,
          orElse: () => _tracks.first,
        );
        await play(prevTrack);
        return;
      }
    }
    final currentIndex = _tracks.indexWhere((t) => t.id == _currentTrack?.id);
    final prevIndex = (currentIndex - 1 + _tracks.length) % _tracks.length;
    await play(_tracks[prevIndex]);
  }

  @override
  Future<void> removeTrack(
    String trackId, {
    bool deleteFromDevice = false,
  }) async {
    final trackIndex = _tracks.indexWhere((t) => t.id == trackId);
    if (trackIndex == -1) return;
    final track = _tracks[trackIndex];

    if (deleteFromDevice) {
      await _deletePhysicalFiles([track]);
    }

    final isDeletingCurrent = _currentTrack?.id == trackId;
    _tracks.removeAt(trackIndex);
    _shuffledOrder.remove(trackId);

    if (isDeletingCurrent) {
      if (_tracks.isNotEmpty) {
        await play(_tracks.first);
      } else {
        await pause();
        _currentTrack = null;
        _currentTrackController.add(null);
      }
    }
  }

  @override
  Future<void> removeTracks(
    List<String> trackIds, {
    bool deleteFromDevice = false,
  }) async {
    final idSet = trackIds.toSet();
    final tracksToDelete = _tracks.where((t) => idSet.contains(t.id)).toList();

    if (deleteFromDevice && tracksToDelete.isNotEmpty) {
      await _deletePhysicalFiles(tracksToDelete);
    }

    final isDeletingCurrent =
        _currentTrack != null && idSet.contains(_currentTrack!.id);
    _tracks.removeWhere((t) => idSet.contains(t.id));
    _shuffledOrder.removeWhere((id) => idSet.contains(id));

    if (isDeletingCurrent) {
      if (_tracks.isNotEmpty) {
        await play(_tracks.first);
      } else {
        await pause();
        _currentTrack = null;
        _currentTrackController.add(null);
      }
    }
  }

  Future<void> _deletePhysicalFiles(List<Track> tracks) async {
    if (tracks.isEmpty) return;
    try {
      await _localAudioDataSource.deletePhysicalTracks(tracks);
    } catch (e) {
      debugPrint(
        'AudioPlayerRepositoryImpl._deletePhysicalFiles exception: $e',
      );
      _playbackErrorController.add('Could not delete physical audio files: $e');
    }
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
    if (_audioHandler != null) {
      _audioHandler.dispose();
    } else {
      _player.dispose();
    }
    _isPlayingController.close();
    _positionController.close();
    _durationController.close();
    _currentTrackController.close();
    _playbackErrorController.close();
    _repeatModeController.close();
  }
}
