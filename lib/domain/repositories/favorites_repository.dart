import 'package:media_player/domain/entities/favorite_track.dart';

abstract class FavoritesRepository {
  Future<List<FavoriteTrack>> getFavorites();
  Future<void> addFavorite(FavoriteTrack favorite);
  Future<void> removeFavorite(String trackId);
  Future<bool> isFavorite(String trackId);
  Future<void> toggleFavorite(FavoriteTrack favorite);
  Stream<List<FavoriteTrack>> get favoritesStream;
}
