import 'package:equatable/equatable.dart';

class Track extends Equatable {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    this.audioUrl = '',
    this.genre = 'Pop',
    this.isFavorite = false,
    this.isSelected = false,
    this.coverUrl,
  });

  final String id;
  final String title;
  final String artist;
  final Duration duration;
  final String audioUrl;
  final String genre;
  final bool isFavorite;
  final bool isSelected;
  final String? coverUrl;

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    Duration? duration,
    String? audioUrl,
    String? genre,
    bool? isFavorite,
    bool? isSelected,
    String? coverUrl,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      genre: genre ?? this.genre,
      isFavorite: isFavorite ?? this.isFavorite,
      isSelected: isSelected ?? this.isSelected,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    artist,
    duration,
    audioUrl,
    genre,
    isFavorite,
    isSelected,
    coverUrl,
  ];
}
