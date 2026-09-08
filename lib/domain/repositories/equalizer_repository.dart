import 'package:media_player/domain/entities/equalizer_setting.dart';
import 'package:media_player/domain/value_objects/equalizer_gain.dart';

abstract class EqualizerRepository {
  Future<EqualizerSetting> getEqualizerSetting();
  Future<void> updateBandGain(String bandId, EqualizerGain gain);
  Future<void> updateBass(double bass);
  Future<void> updateTreble(double treble);
  Future<void> updateVocal(double vocal);
  Future<void> selectPreset(String preset);
  Future<void> saveSettings();
}
