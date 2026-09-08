import 'package:equatable/equatable.dart';

/// Value object representing an FM radio frequency between 87.5 MHz and 108.0 MHz.
class AudioFrequency extends Equatable {
  const AudioFrequency(this.mhz)
    : assert(
        mhz >= 87.5 && mhz <= 108.0,
        'FM Frequency must be between 87.5 and 108.0 MHz',
      );

  final double mhz;

  String get formatted => '${mhz.toStringAsFixed(1)} MHz';

  @override
  List<Object?> get props => [mhz];
}
