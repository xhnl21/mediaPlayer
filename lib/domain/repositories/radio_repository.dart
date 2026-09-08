import 'package:media_player/domain/entities/radio_station.dart';
import 'package:media_player/domain/value_objects/audio_frequency.dart';

abstract class RadioRepository {
  Stream<bool> get isPlayingStream;
  Stream<double> get volumeStream;
  Stream<AudioFrequency> get currentFrequencyStream;
  Stream<RadioStation?> get currentStationStream;

  Future<List<RadioStation>> getStations();
  Future<void> tuneFrequency(AudioFrequency frequency);
  Future<void> play();
  Future<void> pause();
  Future<void> nextStation();
  Future<void> previousStation();
  Future<void> setVolume(double volume);
}
