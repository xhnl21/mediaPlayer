import 'package:media_player/domain/entities/radio_station.dart';
import 'package:media_player/domain/repositories/radio_repository.dart';
import 'package:media_player/domain/value_objects/audio_frequency.dart';

class GetRadioStationsUseCase {
  const GetRadioStationsUseCase(this._repository);
  final RadioRepository _repository;

  Future<List<RadioStation>> execute() => _repository.getStations();
}

class TuneRadioFrequencyUseCase {
  const TuneRadioFrequencyUseCase(this._repository);
  final RadioRepository _repository;

  Future<void> execute(AudioFrequency frequency) =>
      _repository.tuneFrequency(frequency);
}

class ToggleRadioPlaybackUseCase {
  const ToggleRadioPlaybackUseCase(this._repository);
  final RadioRepository _repository;

  Future<void> execute({required bool isCurrentlyPlaying}) async {
    if (isCurrentlyPlaying) {
      await _repository.pause();
    } else {
      await _repository.play();
    }
  }
}

class NextRadioStationUseCase {
  const NextRadioStationUseCase(this._repository);
  final RadioRepository _repository;

  Future<void> execute() => _repository.nextStation();
}

class PreviousRadioStationUseCase {
  const PreviousRadioStationUseCase(this._repository);
  final RadioRepository _repository;

  Future<void> execute() => _repository.previousStation();
}

class SetRadioVolumeUseCase {
  const SetRadioVolumeUseCase(this._repository);
  final RadioRepository _repository;

  Future<void> execute(double volume) => _repository.setVolume(volume);
}
