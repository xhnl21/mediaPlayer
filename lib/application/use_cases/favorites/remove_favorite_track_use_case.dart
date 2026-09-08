import 'package:media_player/domain/favorites.dart';

class RemoveFavoriteTrackUseCase {
  const RemoveFavoriteTrackUseCase(this._repository);

  final FavoritesRepository _repository;

  Future<void> execute(String trackId) => _repository.removeFavorite(trackId);
}
