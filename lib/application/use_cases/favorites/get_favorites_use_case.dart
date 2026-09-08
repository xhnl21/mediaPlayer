import 'package:media_player/domain/favorites.dart';

class GetFavoritesUseCase {
  const GetFavoritesUseCase(this._repository);

  final FavoritesRepository _repository;

  Future<List<FavoriteTrack>> execute() => _repository.getFavorites();
}
