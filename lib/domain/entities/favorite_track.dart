import 'package:equatable/equatable.dart';

class FavoriteTrack extends Equatable {
  const FavoriteTrack({
    required this.id,
    required this.trackId,
    required this.title,
    required this.artist,
    this.album = '',
    required this.duration,
    this.audioUrl = '',
    required this.addedAt,
  });

  /// Mandatory UUID v4 primary identifier
  final String id;
  final String trackId;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String audioUrl;
  final DateTime addedAt;

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  FavoriteTrack copyWith({
    String? id,
    String? trackId,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    String? audioUrl,
    DateTime? addedAt,
  }) {
    return FavoriteTrack(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    trackId,
    title,
    artist,
    album,
    duration,
    audioUrl,
    addedAt,
  ];
}
