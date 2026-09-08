import 'package:media_player/domain/player.dart';

class RemoveTrackUseCase {
  const RemoveTrackUseCase(this._repository);

  final AudioPlayerRepository _repository;

  Future<void> execute(String trackId, {bool deleteFromDevice = false}) =>
      _repository.removeTrack(trackId, deleteFromDevice: deleteFromDevice);
}

class RemoveTracksUseCase {
  const RemoveTracksUseCase(this._repository);

  final AudioPlayerRepository _repository;

  Future<void> execute(
    List<String> trackIds, {
    bool deleteFromDevice = false,
  }) => _repository.removeTracks(trackIds, deleteFromDevice: deleteFromDevice);
}

class SetRepeatModeUseCase {
  const SetRepeatModeUseCase(this._repository);

  final AudioPlayerRepository _repository;

  Future<void> execute(AudioRepeatMode mode) => _repository.setRepeatMode(mode);
}

class SetShuffleModeUseCase {
  const SetShuffleModeUseCase(this._repository);

  final AudioPlayerRepository _repository;

  Future<void> execute(bool enabled) => _repository.setShuffle(enabled);
}
