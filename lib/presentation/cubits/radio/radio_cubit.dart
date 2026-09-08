import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/application/radio.dart';
import 'package:media_player/domain/radio.dart';

class RadioState extends Equatable {
  const RadioState({
    this.stations = const [],
    this.currentStation,
    this.frequency = const AudioFrequency(102.5),
    this.isPlaying = true,
    this.volume = 0.75,
  });

  final List<RadioStation> stations;
  final RadioStation? currentStation;
  final AudioFrequency frequency;
  final bool isPlaying;
  final double volume;

  RadioState copyWith({
    List<RadioStation>? stations,
    RadioStation? currentStation,
    AudioFrequency? frequency,
    bool? isPlaying,
    double? volume,
  }) {
    return RadioState(
      stations: stations ?? this.stations,
      currentStation: currentStation ?? this.currentStation,
      frequency: frequency ?? this.frequency,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
    );
  }

  @override
  List<Object?> get props => [
    stations,
    currentStation,
    frequency,
    isPlaying,
    volume,
  ];
}

class RadioCubit extends Cubit<RadioState> {
  RadioCubit({
    required this.radioRepository,
    required this.getRadioStationsUseCase,
    required this.tuneRadioFrequencyUseCase,
    required this.toggleRadioPlaybackUseCase,
    required this.nextRadioStationUseCase,
    required this.previousRadioStationUseCase,
    required this.setRadioVolumeUseCase,
  }) : super(const RadioState()) {
    _initSubscriptions();
  }

  final RadioRepository radioRepository;
  final GetRadioStationsUseCase getRadioStationsUseCase;
  final TuneRadioFrequencyUseCase tuneRadioFrequencyUseCase;
  final ToggleRadioPlaybackUseCase toggleRadioPlaybackUseCase;
  final NextRadioStationUseCase nextRadioStationUseCase;
  final PreviousRadioStationUseCase previousRadioStationUseCase;
  final SetRadioVolumeUseCase setRadioVolumeUseCase;

  StreamSubscription<AudioFrequency>? _freqSub;
  StreamSubscription<RadioStation?>? _stationSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<double>? _volumeSub;

  void _initSubscriptions() {
    _freqSub = radioRepository.currentFrequencyStream.listen((freq) {
      emit(state.copyWith(frequency: freq));
    });
    _stationSub = radioRepository.currentStationStream.listen((st) {
      emit(state.copyWith(currentStation: st));
    });
    _playingSub = radioRepository.isPlayingStream.listen((playing) {
      emit(state.copyWith(isPlaying: playing));
    });
    _volumeSub = radioRepository.volumeStream.listen((vol) {
      emit(state.copyWith(volume: vol));
    });

    loadInitialData();
  }

  Future<void> loadInitialData() async {
    final stations = await getRadioStationsUseCase.execute();
    emit(
      state.copyWith(
        stations: stations,
        currentStation: stations.isNotEmpty ? stations.first : null,
        frequency: stations.isNotEmpty
            ? stations.first.frequency
            : const AudioFrequency(102.5),
      ),
    );
  }

  Future<void> tune(double mhz) async {
    final freq = AudioFrequency(mhz);
    await tuneRadioFrequencyUseCase.execute(freq);
  }

  Future<void> togglePlayback() async {
    await toggleRadioPlaybackUseCase.execute(
      isCurrentlyPlaying: state.isPlaying,
    );
  }

  Future<void> nextStation() async {
    await nextRadioStationUseCase.execute();
  }

  Future<void> previousStation() async {
    await previousRadioStationUseCase.execute();
  }

  Future<void> setVolume(double volume) async {
    await setRadioVolumeUseCase.execute(volume);
  }

  @override
  Future<void> close() {
    _freqSub?.cancel();
    _stationSub?.cancel();
    _playingSub?.cancel();
    _volumeSub?.cancel();
    return super.close();
  }
}
