import 'package:equatable/equatable.dart';

/// Value object representing Equalizer band gain (-12.0 dB to +12.0 dB).
class EqualizerGain extends Equatable {
  const EqualizerGain(double value)
    : value = value < -12.0
          ? -12.0
          : value > 12.0
          ? 12.0
          : value;

  final double value;

  /// Returns normalized value from 0.0 to 1.0 for UI sliders.
  double get normalized => (value + 12.0) / 24.0;

  /// Constructs from normalized 0.0 - 1.0 slider value.
  factory EqualizerGain.fromNormalized(double norm) {
    final clamped = norm.clamp(0.0, 1.0);
    return EqualizerGain((clamped * 24.0) - 12.0);
  }

  @override
  List<Object?> get props => [value];
}
