import 'package:media_player/domain/entities/playlist.dart';
import 'package:media_player/domain/entities/track.dart';

abstract class AudioPlayerRepository {
  Stream<bool> get isPlayingStream;
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  Stream<Track?> get currentTrackStream;

  Future<void> play(Track track);
  Future<void> pause();
  Future<void> resume();
  Future<void> seek(Duration position);
  Future<void> next();
  Future<void> previous();

  Future<List<Playlist>> getPlaylists();
  Future<List<Track>> getTracks();
  Future<List<Track>> searchTracks(String query);
  Future<void> toggleFavorite(String trackId);
  Future<void> toggleSelect(String trackId);
}
