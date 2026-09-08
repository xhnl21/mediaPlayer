import 'package:media_player/domain/entities/audio_settings.dart';

abstract class SettingsRepository {
  Future<AudioSettings> getSettings();
  Future<void> updateSettings(AudioSettings settings);
  Future<void> saveSettings();
}
