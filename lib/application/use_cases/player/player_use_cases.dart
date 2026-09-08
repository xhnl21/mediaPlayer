import 'package:media_player/domain/entities/playlist.dart';
import 'package:media_player/domain/entities/track.dart';
import 'package:media_player/domain/repositories/audio_player_repository.dart';

class PlayTrackUseCase {
  const PlayTrackUseCase(this._repository);
  final AudioPlayerRepository _repository;

  Future<void> execute(Track track) => _repository.play(track);
}

class PauseTrackUseCase {
  const PauseTrackUseCase(this._repository);
  final AudioPlayerRepository _repository;

  Future<void> execute() => _repository.pause();
}

class ResumeTrackUseCase {
  const ResumeTrackUseCase(this._repository);
  final AudioPlayerRepository _repository;

  Future<void> execute() => _repository.resume();
}

class SeekTrackUseCase {
  const SeekTrackUseCase(this._repository);
  final AudioPlayerRepository _repository;

  Future<void> execute(Duration position) => _repository.seek(position);
}

class NextTrackUseCase {
  const NextTrackUseCase(this._repository);
  final AudioPlayerRepository _repository;

  Future<void> execute() => _repository.next();
}

class PreviousTrackUseCase {
  const PreviousTrackUseCase(this._repository);
  final AudioPlayerRepository _repository;

  Future<void> execute() => _repository.previous();
}

class GetPlaylistsUseCase {
  const GetPlaylistsUseCase(this._repository);
  final AudioPlayerRepository _repository;

  Future<List<Playlist>> execute() => _repository.getPlaylists();
}

class GetTracksUseCase {
  const GetTracksUseCase(this._repository);
  final AudioPlayerRepository _repository;

  Future<List<Track>> execute() => _repository.getTracks();
}

class SearchTracksUseCase {
  const SearchTracksUseCase(this._repository);
  final AudioPlayerRepository _repository;

  Future<List<Track>> execute(String query) => _repository.searchTracks(query);
}

class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase(this._repository);
  final AudioPlayerRepository _repository;

  Future<void> execute(String trackId) => _repository.toggleFavorite(trackId);
}

class ToggleSelectUseCase {
  const ToggleSelectUseCase(this._repository);
  final AudioPlayerRepository _repository;

  Future<void> execute(String trackId) => _repository.toggleSelect(trackId);
}
