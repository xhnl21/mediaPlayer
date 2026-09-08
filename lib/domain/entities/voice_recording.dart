import 'package:equatable/equatable.dart';

class VoiceRecording extends Equatable {
  const VoiceRecording({
    required this.id,
    required this.title,
    required this.duration,
    required this.createdAt,
    this.filePath = '',
  });

  final String id;
  final String title;
  final Duration duration;
  final DateTime createdAt;
  final String filePath;

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  List<Object?> get props => [id, title, duration, createdAt, filePath];
}
