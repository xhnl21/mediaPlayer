import 'dart:async';

import 'package:media_player/domain/entities/radio_station.dart';
import 'package:media_player/domain/repositories/radio_repository.dart';
import 'package:media_player/domain/value_objects/audio_frequency.dart';
import 'package:media_player/infrastructure/datasources/music_mock_data_source.dart';

class RadioRepositoryImpl implements RadioRepository {
  RadioRepositoryImpl() {
    _stations = List<RadioStation>.from(MusicMockDataSource.defaultStations);
    _currentStation = _stations.first;
    _currentFrequency =
        _currentStation?.frequency ?? const AudioFrequency(102.5);

    _frequencyController.add(_currentFrequency);
    _stationController.add(_currentStation);
    _volumeController.add(_volume);
    _isPlayingController.add(_isPlaying);
  }

  late final List<RadioStation> _stations;
  RadioStation? _currentStation;
  AudioFrequency _currentFrequency = const AudioFrequency(102.5);
  bool _isPlaying = true;
  double _volume = 0.75;

  final _isPlayingController = StreamController<bool>.broadcast();
  final _volumeController = StreamController<double>.broadcast();
  final _frequencyController = StreamController<AudioFrequency>.broadcast();
  final _stationController = StreamController<RadioStation?>.broadcast();

  @override
  Stream<bool> get isPlayingStream => _isPlayingController.stream;

  @override
  Stream<double> get volumeStream => _volumeController.stream;

  @override
  Stream<AudioFrequency> get currentFrequencyStream =>
      _frequencyController.stream;

  @override
  Stream<RadioStation?> get currentStationStream => _stationController.stream;

  @override
  Future<List<RadioStation>> getStations() async =>
      List.unmodifiable(_stations);

  @override
  Future<void> tuneFrequency(AudioFrequency frequency) async {
    _currentFrequency = frequency;
    _frequencyController.add(_currentFrequency);

    // Find closest station or create virtual station for frequency
    final match = _stations.firstWhere(
      (s) => (s.frequency.mhz - frequency.mhz).abs() < 0.1,
      orElse: () => RadioStation(
        id: 'virtual_${frequency.mhz}',
        name: 'Station ${frequency.formatted}',
        description: 'Live broadcast on ${frequency.formatted}',
        frequency: frequency,
      ),
    );
    _currentStation = match;
    _stationController.add(_currentStation);
  }

  @override
  Future<void> play() async {
    _isPlaying = true;
    _isPlayingController.add(true);
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
    _isPlayingController.add(false);
  }

  @override
  Future<void> nextStation() async {
    if (_stations.isEmpty) return;
    final currentIndex = _stations.indexWhere(
      (s) => s.id == _currentStation?.id,
    );
    final nextIndex = (currentIndex + 1) % _stations.length;
    final nextStation = _stations[nextIndex];
    await tuneFrequency(nextStation.frequency);
  }

  @override
  Future<void> previousStation() async {
    if (_stations.isEmpty) return;
    final currentIndex = _stations.indexWhere(
      (s) => s.id == _currentStation?.id,
    );
    final prevIndex = (currentIndex - 1 + _stations.length) % _stations.length;
    final prevStation = _stations[prevIndex];
    await tuneFrequency(prevStation.frequency);
  }

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    _volumeController.add(_volume);
  }

  void dispose() {
    _isPlayingController.close();
    _volumeController.close();
    _frequencyController.close();
    _stationController.close();
  }
}
