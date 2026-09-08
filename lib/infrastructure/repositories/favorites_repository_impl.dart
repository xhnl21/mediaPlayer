import 'dart:async';

import 'package:media_player/domain/entities/favorite_track.dart';
import 'package:media_player/domain/repositories/favorites_repository.dart';
import 'package:media_player/infrastructure/datasources/database/app_database.dart';
import 'package:media_player/infrastructure/datasources/database/drift_favorites_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl({required this.dataSource}) {
    _initSubscription();
  }

  final DriftFavoritesDataSource dataSource;
  final _favoritesController =
      StreamController<List<FavoriteTrack>>.broadcast();
  StreamSubscription<List<FavoriteTrackEntry>>? _subscription;

  void _initSubscription() {
    _subscription = dataSource.watchAllFavorites().listen((entries) {
      final tracks = entries.map(_toDomain).toList();
      _favoritesController.add(tracks);
    });
  }

  @override
  Stream<List<FavoriteTrack>> get favoritesStream =>
      _favoritesController.stream;

  @override
  Future<List<FavoriteTrack>> getFavorites() async {
    final entries = await dataSource.getAllFavorites();
    return entries.map(_toDomain).toList();
  }

  @override
  Future<void> addFavorite(FavoriteTrack favorite) async {
    await dataSource.insertFavorite(
      id: favorite.id,
      trackId: favorite.trackId,
      title: favorite.title,
      artist: favorite.artist,
      album: favorite.album,
      durationMs: favorite.duration.inMilliseconds,
      audioUrl: favorite.audioUrl,
      addedAt: favorite.addedAt,
    );
  }

  @override
  Future<void> removeFavorite(String trackId) async {
    await dataSource.deleteFavoriteByTrackId(trackId);
  }

  @override
  Future<bool> isFavorite(String trackId) => dataSource.isFavorite(trackId);

  @override
  Future<void> toggleFavorite(FavoriteTrack favorite) async {
    final exists = await dataSource.isFavorite(favorite.trackId);
    if (exists) {
      await removeFavorite(favorite.trackId);
    } else {
      await addFavorite(favorite);
    }
  }

  FavoriteTrack _toDomain(FavoriteTrackEntry entry) {
    return FavoriteTrack(
      id: entry.id,
      trackId: entry.trackId,
      title: entry.title,
      artist: entry.artist,
      album: entry.album,
      duration: Duration(milliseconds: entry.durationMs),
      audioUrl: entry.audioUrl,
      addedAt: entry.addedAt,
    );
  }

  void dispose() {
    _subscription?.cancel();
    _favoritesController.close();
  }
}
