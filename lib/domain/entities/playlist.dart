import 'package:equatable/equatable.dart';
import 'package:media_player/domain/entities/track.dart';

class Playlist extends Equatable {
  const Playlist({
    required this.id,
    required this.title,
    required this.dateSubtitle,
    required this.songCount,
    required this.durationMinutes,
    this.rating = 4.5,
    this.description = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    this.tracks = const [],
    this.isFeatured = false,
  });

  final String id;
  final String title;
  final String dateSubtitle;
  final int songCount;
  final int durationMinutes;
  final double rating;
  final String description;
  final List<Track> tracks;
  final bool isFeatured;

  String get metaInfo =>
      '$dateSubtitle / $songCount songs / $durationMinutes minutes';

  Playlist copyWith({
    String? id,
    String? title,
    String? dateSubtitle,
    int? songCount,
    int? durationMinutes,
    double? rating,
    String? description,
    List<Track>? tracks,
    bool? isFeatured,
  }) {
    return Playlist(
      id: id ?? this.id,
      title: title ?? this.title,
      dateSubtitle: dateSubtitle ?? this.dateSubtitle,
      songCount: songCount ?? this.songCount,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      tracks: tracks ?? this.tracks,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    dateSubtitle,
    songCount,
    durationMinutes,
    rating,
    description,
    tracks,
    isFeatured,
  ];
}
