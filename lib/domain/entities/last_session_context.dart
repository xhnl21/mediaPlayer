import 'package:equatable/equatable.dart';

/// Represents the snapshot of playback state and track from the previous session.
class LastSessionContext extends Equatable {
  const LastSessionContext({
    required this.trackId,
    required this.index,
    required this.position,
    this.title = '',
    this.artist = '',
    this.album = '',
    this.audioUrl = '',
    this.duration = Duration.zero,
  });

  final String trackId;
  final int index;
  final Duration position;
  final String title;
  final String artist;
  final String album;
  final String audioUrl;
  final Duration duration;

  @override
  List<Object?> get props => [
    trackId,
    index,
    position,
    title,
    artist,
    album,
    audioUrl,
    duration,
  ];
}
