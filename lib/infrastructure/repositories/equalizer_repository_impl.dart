import 'package:media_player/domain/entities/equalizer_setting.dart';
import 'package:media_player/domain/repositories/equalizer_repository.dart';
import 'package:media_player/domain/value_objects/equalizer_gain.dart';
import 'package:media_player/infrastructure/datasources/secure_encrypted_data_source.dart';

class EqualizerRepositoryImpl implements EqualizerRepository {
  EqualizerRepositoryImpl({required this.secureDataSource});

  final SecureEncryptedDataSource secureDataSource;
  static const String _storageKey = 'EQUALIZER_SETTINGS_ENCRYPTED';

  EqualizerSetting _currentSetting = EqualizerSetting.initial();

  @override
  Future<EqualizerSetting> getEqualizerSetting() async {
    final data = await secureDataSource.getEncryptedJson(key: _storageKey);
    if (data != null) {
      final bass = (data['bass'] as num?)?.toDouble() ?? 0.65;
      final treble = (data['treble'] as num?)?.toDouble() ?? 0.40;
      final vocal = (data['vocal'] as num?)?.toDouble() ?? 0.80;
      final preset = data['preset'] as String? ?? 'Dolor';

      final rawBands = data['bands'] as List<dynamic>? ?? [];
      final bands = rawBands.map((b) {
        return EqualizerBand(
          id: b['id'] as String,
          label: b['label'] as String,
          gain: EqualizerGain((b['gain'] as num).toDouble()),
        );
      }).toList();

      if (bands.isNotEmpty) {
        _currentSetting = EqualizerSetting(
          bands: bands,
          bass: bass,
          treble: treble,
          vocal: vocal,
          selectedPreset: preset,
        );
      }
    }
    return _currentSetting;
  }

  @override
  Future<void> updateBandGain(String bandId, EqualizerGain gain) async {
    final updatedBands = _currentSetting.bands.map((b) {
      if (b.id == bandId) {
        return b.copyWith(gain: gain);
      }
      return b;
    }).toList();
    _currentSetting = _currentSetting.copyWith(bands: updatedBands);
  }

  @override
  Future<void> updateBass(double bass) async {
    _currentSetting = _currentSetting.copyWith(bass: bass.clamp(0.0, 1.0));
  }

  @override
  Future<void> updateTreble(double treble) async {
    _currentSetting = _currentSetting.copyWith(treble: treble.clamp(0.0, 1.0));
  }

  @override
  Future<void> updateVocal(double vocal) async {
    _currentSetting = _currentSetting.copyWith(vocal: vocal.clamp(0.0, 1.0));
  }

  @override
  Future<void> selectPreset(String preset) async {
    _currentSetting = _currentSetting.copyWith(selectedPreset: preset);
  }

  @override
  Future<void> saveSettings() async {
    final bandsJson = _currentSetting.bands
        .map((b) => {'id': b.id, 'label': b.label, 'gain': b.gain.value})
        .toList();

    await secureDataSource.saveEncryptedJson(
      key: _storageKey,
      data: {
        'bass': _currentSetting.bass,
        'treble': _currentSetting.treble,
        'vocal': _currentSetting.vocal,
        'preset': _currentSetting.selectedPreset,
        'bands': bandsJson,
      },
    );
  }
}
