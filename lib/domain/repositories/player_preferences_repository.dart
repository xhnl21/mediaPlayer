import 'package:media_player/domain/entities/last_session_context.dart';
import 'package:media_player/domain/entities/repeat_mode.dart';
import 'package:media_player/domain/entities/track.dart';

abstract class PlayerPreferencesRepository {
  Future<void> saveRepeatMode(AudioRepeatMode mode);
  Future<AudioRepeatMode> getRepeatMode();

  Future<void> saveShuffleEnabled(bool enabled);
  Future<bool> isShuffleEnabled();

  Future<void> saveLastTrack(Track track, int index, Duration position);
  Future<LastSessionContext?> getLastTrack();
}

/// Domain alias
typedef PreferencesRepository = PlayerPreferencesRepository;
