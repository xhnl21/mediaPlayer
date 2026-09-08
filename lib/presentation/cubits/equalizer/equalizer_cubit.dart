import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/application/equalizer.dart';
import 'package:media_player/domain/equalizer.dart';

class EqualizerState extends Equatable {
  const EqualizerState({required this.setting, this.isSaved = false});

  final EqualizerSetting setting;
  final bool isSaved;

  EqualizerState copyWith({EqualizerSetting? setting, bool? isSaved}) {
    return EqualizerState(
      setting: setting ?? this.setting,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [setting, isSaved];
}

class EqualizerCubit extends Cubit<EqualizerState> {
  EqualizerCubit({
    required this.getEqualizerSettingUseCase,
    required this.updateEqualizerBandUseCase,
    required this.updateEqualizerDialsUseCase,
    required this.selectEqualizerPresetUseCase,
    required this.saveEqualizerSettingsUseCase,
  }) : super(EqualizerState(setting: EqualizerSetting.initial())) {
    loadSettings();
  }

  final GetEqualizerSettingUseCase getEqualizerSettingUseCase;
  final UpdateEqualizerBandUseCase updateEqualizerBandUseCase;
  final UpdateEqualizerDialsUseCase updateEqualizerDialsUseCase;
  final SelectEqualizerPresetUseCase selectEqualizerPresetUseCase;
  final SaveEqualizerSettingsUseCase saveEqualizerSettingsUseCase;

  Future<void> loadSettings() async {
    final setting = await getEqualizerSettingUseCase.execute();
    emit(state.copyWith(setting: setting));
  }

  Future<void> setBandGain(String bandId, double normalizedGain) async {
    final gain = EqualizerGain.fromNormalized(normalizedGain);
    await updateEqualizerBandUseCase.execute(bandId, gain);

    final updatedBands = state.setting.bands.map((b) {
      if (b.id == bandId) {
        return b.copyWith(gain: gain);
      }
      return b;
    }).toList();

    emit(
      state.copyWith(
        setting: state.setting.copyWith(bands: updatedBands),
        isSaved: false,
      ),
    );
  }

  Future<void> setBass(double bass) async {
    await updateEqualizerDialsUseCase.execute(bass: bass);
    emit(
      state.copyWith(
        setting: state.setting.copyWith(bass: bass.clamp(0.0, 1.0)),
        isSaved: false,
      ),
    );
  }

  Future<void> setTreble(double treble) async {
    await updateEqualizerDialsUseCase.execute(treble: treble);
    emit(
      state.copyWith(
        setting: state.setting.copyWith(treble: treble.clamp(0.0, 1.0)),
        isSaved: false,
      ),
    );
  }

  Future<void> setVocal(double vocal) async {
    await updateEqualizerDialsUseCase.execute(vocal: vocal);
    emit(
      state.copyWith(
        setting: state.setting.copyWith(vocal: vocal.clamp(0.0, 1.0)),
        isSaved: false,
      ),
    );
  }

  Future<void> selectPreset(String preset) async {
    await selectEqualizerPresetUseCase.execute(preset);
    emit(
      state.copyWith(
        setting: state.setting.copyWith(selectedPreset: preset),
        isSaved: false,
      ),
    );
  }

  Future<void> save() async {
    await saveEqualizerSettingsUseCase.execute();
    emit(state.copyWith(isSaved: true));
  }
}
