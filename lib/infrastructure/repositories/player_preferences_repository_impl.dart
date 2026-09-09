import 'package:flutter/foundation.dart';
import 'package:media_player/domain/entities/last_session_context.dart';
import 'package:media_player/domain/entities/repeat_mode.dart';
import 'package:media_player/domain/entities/track.dart';
import 'package:media_player/domain/repositories/player_preferences_repository.dart';
import 'package:media_player/infrastructure/datasources/secure_encrypted_data_source.dart';

class PlayerPreferencesRepositoryImpl implements PlayerPreferencesRepository {
  PlayerPreferencesRepositoryImpl({required this.secureDataSource});

  final SecureEncryptedDataSource secureDataSource;

  static const String _keyRepeatMode = 'PLAYER_PREF_REPEAT_MODE';
  static const String _keyShuffle = 'PLAYER_PREF_SHUFFLE_MODE';
  static const String _keyLastSession = 'PLAYER_PREF_LAST_SESSION';

  @override
  Future<void> saveRepeatMode(AudioRepeatMode mode) async {
    try {
      await secureDataSource.saveEncryptedJson(
        key: _keyRepeatMode,
        data: {'mode': mode.name},
      );
    } catch (e) {
      debugPrint('PreferencesRepository: Error saving repeat mode: $e');
    }
  }

  @override
  Future<AudioRepeatMode> getRepeatMode() async {
    try {
      final data = await secureDataSource.getEncryptedJson(key: _keyRepeatMode);
      if (data != null && data['mode'] is String) {
        final modeName = data['mode'] as String;
        return AudioRepeatMode.values.firstWhere(
          (m) => m.name == modeName,
          orElse: () => AudioRepeatMode.off,
        );
      }
    } catch (e) {
      debugPrint('PreferencesRepository: Error loading repeat mode: $e');
    }
    return AudioRepeatMode.off;
  }

  @override
  Future<void> saveShuffleEnabled(bool enabled) async {
    try {
      await secureDataSource.saveEncryptedJson(
        key: _keyShuffle,
        data: {'enabled': enabled},
      );
    } catch (e) {
      debugPrint('PreferencesRepository: Error saving shuffle state: $e');
    }
  }

  @override
  Future<bool> isShuffleEnabled() async {
    try {
      final data = await secureDataSource.getEncryptedJson(key: _keyShuffle);
      if (data != null && data['enabled'] is bool) {
        return data['enabled'] as bool;
      }
    } catch (e) {
      debugPrint('PreferencesRepository: Error loading shuffle state: $e');
    }
    return false;
  }

  @override
  Future<void> saveLastTrack(Track track, int index, Duration position) async {
    try {
      await secureDataSource.saveEncryptedJson(
        key: _keyLastSession,
        data: {
          'trackId': track.id,
          'index': index,
          'positionMs': position.inMilliseconds,
          'title': track.title,
          'artist': track.artist,
          'album': track.album,
          'audioUrl': track.audioUrl,
          'durationMs': track.duration.inMilliseconds,
        },
      );
    } catch (e) {
      debugPrint('PreferencesRepository: Error saving last track: $e');
    }
  }

  @override
  Future<LastSessionContext?> getLastTrack() async {
    try {
      final data = await secureDataSource.getEncryptedJson(
        key: _keyLastSession,
      );
      if (data != null && data['trackId'] is String) {
        return LastSessionContext(
          trackId: data['trackId'] as String,
          index: (data['index'] as num?)?.toInt() ?? 0,
          position: Duration(
            milliseconds: (data['positionMs'] as num?)?.toInt() ?? 0,
          ),
          title: data['title'] as String? ?? '',
          artist: data['artist'] as String? ?? '',
          album: data['album'] as String? ?? '',
          audioUrl: data['audioUrl'] as String? ?? '',
          duration: Duration(
            milliseconds: (data['durationMs'] as num?)?.toInt() ?? 0,
          ),
        );
      }
    } catch (e) {
      debugPrint('PreferencesRepository: Error loading last session: $e');
    }
    return null;
  }
}
