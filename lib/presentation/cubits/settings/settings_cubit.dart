import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/application/settings.dart';
import 'package:media_player/domain/settings.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.settings = const AudioSettings(),
    this.isSaved = false,
  });

  final AudioSettings settings;
  final bool isSaved;

  SettingsState copyWith({AudioSettings? settings, bool? isSaved}) {
    return SettingsState(
      settings: settings ?? this.settings,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [settings, isSaved];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this.getSettingsUseCase,
    required this.updateSettingsUseCase,
  }) : super(const SettingsState()) {
    loadSettings();
  }

  final GetSettingsUseCase getSettingsUseCase;
  final UpdateSettingsUseCase updateSettingsUseCase;

  Future<void> loadSettings() async {
    final settings = await getSettingsUseCase.execute();
    emit(state.copyWith(settings: settings));
  }

  void toggleLoremIpsum1(bool value) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(loremIpsum1: value),
        isSaved: false,
      ),
    );
  }

  void toggleDolorSitAmet(bool value) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(dolorSitAmet: value),
        isSaved: false,
      ),
    );
  }

  void toggleConsecteturAdipiscing(bool value) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(consecteturAdipiscing: value),
        isSaved: false,
      ),
    );
  }

  void toggleLoremIpsum2(bool value) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(loremIpsum2: value),
        isSaved: false,
      ),
    );
  }

  Future<void> saveSettings() async {
    await updateSettingsUseCase.execute(state.settings);
    emit(state.copyWith(isSaved: true));
  }
}
