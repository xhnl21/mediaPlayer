import 'package:media_player/domain/favorites.dart';

class ToggleFavoriteTrackUseCase {
  const ToggleFavoriteTrackUseCase(this._repository);

  final FavoritesRepository _repository;

  Future<void> execute(FavoriteTrack favorite) =>
      _repository.toggleFavorite(favorite);
}
