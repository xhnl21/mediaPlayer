import 'package:media_player/domain/entities/track.dart';
import 'package:media_player/domain/repositories/audio_player_repository.dart';

class CheckAudioPermissionsUseCase {
  const CheckAudioPermissionsUseCase(this._repository);
  final AudioPlayerRepository _repository;

  Future<bool> execute() => _repository.checkPermissions();
}

class RequestAudioPermissionsUseCase {
  const RequestAudioPermissionsUseCase(this._repository);
  final AudioPlayerRepository _repository;

  Future<bool> execute() => _repository.requestPermissions();
}

class ScanLocalTracksUseCase {
  const ScanLocalTracksUseCase(this._repository);
  final AudioPlayerRepository _repository;

  Future<List<Track>> execute() => _repository.scanLocalTracks();
}
