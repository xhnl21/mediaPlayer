import 'package:media_player/domain/favorites.dart';

class IsFavoriteUseCase {
  const IsFavoriteUseCase(this._repository);

  final FavoritesRepository _repository;

  Future<bool> execute(String trackId) => _repository.isFavorite(trackId);
}
