import 'package:media_player/domain/entities/equalizer_setting.dart';
import 'package:media_player/domain/repositories/equalizer_repository.dart';
import 'package:media_player/domain/value_objects/equalizer_gain.dart';

class GetEqualizerSettingUseCase {
  const GetEqualizerSettingUseCase(this._repository);
  final EqualizerRepository _repository;

  Future<EqualizerSetting> execute() => _repository.getEqualizerSetting();
}

class UpdateEqualizerBandUseCase {
  const UpdateEqualizerBandUseCase(this._repository);
  final EqualizerRepository _repository;

  Future<void> execute(String bandId, EqualizerGain gain) =>
      _repository.updateBandGain(bandId, gain);
}

class UpdateEqualizerDialsUseCase {
  const UpdateEqualizerDialsUseCase(this._repository);
  final EqualizerRepository _repository;

  Future<void> execute({double? bass, double? treble, double? vocal}) async {
    if (bass != null) await _repository.updateBass(bass);
    if (treble != null) await _repository.updateTreble(treble);
    if (vocal != null) await _repository.updateVocal(vocal);
  }
}

class SelectEqualizerPresetUseCase {
  const SelectEqualizerPresetUseCase(this._repository);
  final EqualizerRepository _repository;

  Future<void> execute(String preset) => _repository.selectPreset(preset);
}

class SaveEqualizerSettingsUseCase {
  const SaveEqualizerSettingsUseCase(this._repository);
  final EqualizerRepository _repository;

  Future<void> execute() => _repository.saveSettings();
}
