import 'package:media_player/domain/entities/audio_settings.dart';
import 'package:media_player/domain/repositories/settings_repository.dart';
import 'package:media_player/infrastructure/datasources/secure_encrypted_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({required this.secureDataSource});

  final SecureEncryptedDataSource secureDataSource;
  static const String _storageKey = 'AUDIO_SETTINGS_ENCRYPTED_PREFS';

  AudioSettings _settings = const AudioSettings();

  @override
  Future<AudioSettings> getSettings() async {
    final data = await secureDataSource.getEncryptedJson(key: _storageKey);
    if (data != null) {
      _settings = AudioSettings(
        loremIpsum1: data['loremIpsum1'] as bool? ?? true,
        dolorSitAmet: data['dolorSitAmet'] as bool? ?? false,
        consecteturAdipiscing: data['consecteturAdipiscing'] as bool? ?? true,
        loremIpsum2: data['loremIpsum2'] as bool? ?? false,
      );
    }
    return _settings;
  }

  @override
  Future<void> updateSettings(AudioSettings settings) async {
    _settings = settings;
  }

  @override
  Future<void> saveSettings() async {
    await secureDataSource.saveEncryptedJson(
      key: _storageKey,
      data: {
        'loremIpsum1': _settings.loremIpsum1,
        'dolorSitAmet': _settings.dolorSitAmet,
        'consecteturAdipiscing': _settings.consecteturAdipiscing,
        'loremIpsum2': _settings.loremIpsum2,
      },
    );
  }
}
