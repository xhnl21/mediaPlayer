import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:media_player/domain/entities/repeat_mode.dart';
import 'package:media_player/domain/entities/track.dart';

/// Audio handler that communicates with the OS media session for lock-screen controls,
/// persistent notification actions, headphone disconnects, and phone call interruptions.
class AudioPlayerHandlerImpl extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  AudioPlayerHandlerImpl({AudioPlayer? player, this.session})
    : _player = player ?? AudioPlayer() {
    _initAudioSession();
    _initPlayerListeners();
  }

  final AudioPlayer _player;
  AudioSession? session;
  bool _playInterrupted = false;

  AudioRepeatMode _repeatMode = AudioRepeatMode.off;
  bool _isShuffle = false;

  VoidCallback? onSkipToNextRequested;
  VoidCallback? onSkipToPreviousRequested;
  VoidCallback? onTrackCompleted;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlaybackEvent>? _playbackEventSub;

  AudioPlayer get player => _player;
  AudioRepeatMode get repeatMode => _repeatMode;
  bool get isShuffle => _isShuffle;

  Future<void> _initAudioSession() async {
    try {
      final activeSession = session ?? await AudioSession.instance;
      session = activeSession;
      await activeSession.configure(const AudioSessionConfiguration.music());

      // Headphone disconnect: pause immediately to prevent unexpected loud speaker audio
      activeSession.becomingNoisyEventStream.listen((_) {
        debugPrint(
          'AudioSession: Headphones disconnected (becoming noisy) -> Pausing',
        );
        pause();
      });

      // Audio interruption (incoming call, alarm, navigation prompt)
      activeSession.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(_player.volume / 2);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              if (_player.playing) {
                _playInterrupted = true;
                pause();
              }
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
              if (_playInterrupted) {
                _playInterrupted = false;
                play();
              }
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });
    } catch (e) {
      debugPrint('AudioSession setup skipped or unavailable: $e');
    }
  }

  void _initPlayerListeners() {
    try {
      _playerStateSub = _player.playerStateStream.listen((state) {
        _broadcastPlaybackState();
        if (state.processingState == ProcessingState.completed) {
          if (onTrackCompleted != null) {
            onTrackCompleted!();
          }
        }
      });

      _positionSub = _player.positionStream.listen((_) {
        _broadcastPlaybackState();
      });

      _durationSub = _player.durationStream.listen((duration) {
        if (duration != null && mediaItem.value != null) {
          mediaItem.add(mediaItem.value!.copyWith(duration: duration));
        }
        _broadcastPlaybackState();
      });

      _playbackEventSub = _player.playbackEventStream.listen((_) {
        _broadcastPlaybackState();
      });
    } catch (e) {
      debugPrint('Error attaching AudioPlayer stream listeners: $e');
    }
  }

  void _broadcastPlaybackState() {
    final playerState = _player.playerState;
    final isPlaying = playerState.playing;
    final processingState = playerState.processingState;

    final audioProcessingState = switch (processingState) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.setRepeatMode,
          MediaAction.setShuffleMode,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: audioProcessingState,
        playing: isPlaying,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
  }

  /// Plays a given domain [Track], updating media notification metadata and audio source.
  Future<void> playTrack(Track track) async {
    final item = MediaItem(
      id: track.id,
      title: track.title,
      artist: track.artist,
      album: track.album.isNotEmpty ? track.album : 'Unknown Album',
      duration: track.duration > Duration.zero ? track.duration : null,
      artUri: track.coverUrl != null && track.coverUrl!.isNotEmpty
          ? Uri.tryParse(track.coverUrl!)
          : null,
    );
    mediaItem.add(item);

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

      await _player.setLoopMode(
        _repeatMode == AudioRepeatMode.all ? LoopMode.one : LoopMode.off,
      );
      await _player.play();
    } else {
      _broadcastPlaybackState();
    }
  }

  /// Updates repeat mode natively and on the media session.
  Future<void> setAudioRepeatMode(AudioRepeatMode mode) async {
    _repeatMode = mode;
    if (mode == AudioRepeatMode.all) {
      await _player.setLoopMode(LoopMode.one);
    } else {
      await _player.setLoopMode(LoopMode.off);
    }
    final serviceRepeatMode = switch (mode) {
      AudioRepeatMode.off => AudioServiceRepeatMode.none,
      AudioRepeatMode.once => AudioServiceRepeatMode.one,
      AudioRepeatMode.all => AudioServiceRepeatMode.all,
    };
    playbackState.add(
      playbackState.value.copyWith(repeatMode: serviceRepeatMode),
    );
  }

  /// Sets shuffle mode.
  void setShuffle(bool enabled) {
    _isShuffle = enabled;
    playbackState.add(
      playbackState.value.copyWith(
        shuffleMode: enabled
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      ),
    );
  }

  // Remote OS controls: Lock screen / notification callbacks
  @override
  Future<void> play() async {
    if (_player.audioSource != null) {
      await _player.play();
    }
    _broadcastPlaybackState();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    _broadcastPlaybackState();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _broadcastPlaybackState();
  }

  @override
  Future<void> skipToNext() async {
    if (onSkipToNextRequested != null) {
      onSkipToNextRequested!();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (onSkipToPreviousRequested != null) {
      onSkipToPreviousRequested!();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  Future<void> dispose() async {
    await _playerStateSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _playbackEventSub?.cancel();
    await _player.dispose();
  }
}
