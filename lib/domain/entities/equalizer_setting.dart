import 'package:equatable/equatable.dart';
import 'package:media_player/domain/value_objects/equalizer_gain.dart';

class EqualizerBand extends Equatable {
  const EqualizerBand({
    required this.id,
    required this.label,
    required this.gain,
  });

  final String id;
  final String label;
  final EqualizerGain gain;

  EqualizerBand copyWith({String? id, String? label, EqualizerGain? gain}) {
    return EqualizerBand(
      id: id ?? this.id,
      label: label ?? this.label,
      gain: gain ?? this.gain,
    );
  }

  @override
  List<Object?> get props => [id, label, gain];
}

class EqualizerSetting extends Equatable {
  const EqualizerSetting({
    required this.bands,
    this.bass = 0.6,
    this.treble = 0.45,
    this.vocal = 0.7,
    this.selectedPreset = 'Dolor',
  });

  final List<EqualizerBand> bands;
  final double bass; // 0.0 to 1.0
  final double treble; // 0.0 to 1.0
  final double vocal; // 0.0 to 1.0
  final String selectedPreset;

  factory EqualizerSetting.initial() {
    return EqualizerSetting(
      bands: [
        EqualizerBand(
          id: 'b1',
          label: '60 Hz',
          gain: EqualizerGain.fromNormalized(0.7),
        ),
        EqualizerBand(
          id: 'b2',
          label: '230 Hz',
          gain: EqualizerGain.fromNormalized(0.85),
        ),
        EqualizerBand(
          id: 'b3',
          label: '14 kHz',
          gain: EqualizerGain.fromNormalized(0.4),
        ),
        EqualizerBand(
          id: 'b4',
          label: '230 Hz',
          gain: EqualizerGain.fromNormalized(0.65),
        ),
        EqualizerBand(
          id: 'b5',
          label: '140 Hz',
          gain: EqualizerGain.fromNormalized(0.75),
        ),
        EqualizerBand(
          id: 'b6',
          label: '40 Hz',
          gain: EqualizerGain.fromNormalized(0.5),
        ),
      ],
      bass: 0.65,
      treble: 0.40,
      vocal: 0.80,
      selectedPreset: 'Dolor',
    );
  }

  EqualizerSetting copyWith({
    List<EqualizerBand>? bands,
    double? bass,
    double? treble,
    double? vocal,
    String? selectedPreset,
  }) {
    return EqualizerSetting(
      bands: bands ?? this.bands,
      bass: bass ?? this.bass,
      treble: treble ?? this.treble,
      vocal: vocal ?? this.vocal,
      selectedPreset: selectedPreset ?? this.selectedPreset,
    );
  }

  @override
  List<Object?> get props => [bands, bass, treble, vocal, selectedPreset];
}
