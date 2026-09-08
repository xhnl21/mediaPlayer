import 'package:drift/drift.dart';
import 'package:media_player/infrastructure/datasources/database/app_database.dart';
import 'package:uuid/uuid.dart';

abstract class DriftFavoritesDataSource {
  Future<List<FavoriteTrackEntry>> getAllFavorites();
  Future<void> insertFavorite({
    String? id,
    required String trackId,
    required String title,
    required String artist,
    String album = '',
    required int durationMs,
    String audioUrl = '',
    DateTime? addedAt,
  });
  Future<void> deleteFavoriteByTrackId(String trackId);
  Future<bool> isFavorite(String trackId);
  Stream<List<FavoriteTrackEntry>> watchAllFavorites();
}

class DriftFavoritesDataSourceImpl implements DriftFavoritesDataSource {
  DriftFavoritesDataSourceImpl(this._database, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final AppDatabase _database;
  final Uuid _uuid;

  @override
  Future<List<FavoriteTrackEntry>> getAllFavorites() async {
    return (_database.select(_database.favoritesTable)..orderBy([
          (t) => OrderingTerm(expression: t.addedAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  @override
  Future<void> insertFavorite({
    String? id,
    required String trackId,
    required String title,
    required String artist,
    String album = '',
    required int durationMs,
    String audioUrl = '',
    DateTime? addedAt,
  }) async {
    // Enforces mandatory UUID primary key
    final entryId = (id != null && id.isNotEmpty) ? id : _uuid.v4();

    await _database
        .into(_database.favoritesTable)
        .insertOnConflictUpdate(
          FavoritesTableCompanion(
            id: Value(entryId),
            trackId: Value(trackId),
            title: Value(title),
            artist: Value(artist),
            album: Value(album),
            durationMs: Value(durationMs),
            audioUrl: Value(audioUrl),
            addedAt: Value(addedAt ?? DateTime.now()),
          ),
        );
  }

  @override
  Future<void> deleteFavoriteByTrackId(String trackId) async {
    await (_database.delete(
      _database.favoritesTable,
    )..where((t) => t.trackId.equals(trackId))).go();
  }

  @override
  Future<bool> isFavorite(String trackId) async {
    final result = await (_database.select(
      _database.favoritesTable,
    )..where((t) => t.trackId.equals(trackId))).getSingleOrNull();
    return result != null;
  }

  @override
  Stream<List<FavoriteTrackEntry>> watchAllFavorites() {
    return (_database.select(_database.favoritesTable)..orderBy([
          (t) => OrderingTerm(expression: t.addedAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }
}
