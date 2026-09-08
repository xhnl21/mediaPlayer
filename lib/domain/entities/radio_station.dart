import 'package:equatable/equatable.dart';
import 'package:media_player/domain/value_objects/audio_frequency.dart';

class RadioStation extends Equatable {
  const RadioStation({
    required this.id,
    required this.name,
    required this.description,
    required this.frequency,
    this.streamUrl = '',
  });

  final String id;
  final String name;
  final String description;
  final AudioFrequency frequency;
  final String streamUrl;

  @override
  List<Object?> get props => [id, name, description, frequency, streamUrl];
}
