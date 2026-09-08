import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/domain/entities/favorite_track.dart';
import 'package:media_player/infrastructure/datasources/database/app_database.dart';
import 'package:media_player/infrastructure/datasources/database/drift_favorites_data_source.dart';
import 'package:media_player/infrastructure/repositories/favorites_repository_impl.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late DriftFavoritesDataSourceImpl dataSource;
  late FavoritesRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dataSource = DriftFavoritesDataSourceImpl(db);
    repository = FavoritesRepositoryImpl(dataSource: dataSource);
  });

  tearDown(() async {
    repository.dispose();
    await db.close();
  });

  group('Drift Favorites Database & UUID v4 Primary Key Verification', () {
    const uuid = Uuid();
    final sampleTrack = FavoriteTrack(
      id: uuid.v4(),
      trackId: 'track-abc-123',
      title: 'Bohemian Rhapsody',
      artist: 'Queen',
      album: 'A Night at the Opera',
      duration: const Duration(minutes: 5, seconds: 55),
      audioUrl: '/storage/emulated/0/Music/queen.mp3',
      addedAt: DateTime.now(),
    );

    test(
      'All inserted favorites must strictly use valid UUID v4 as primary key',
      () async {
        await repository.addFavorite(sampleTrack);

        // Verify UUID v4 format of inserted record
        expect(sampleTrack.id, isNotEmpty);
        expect(Uuid.isValidUUID(fromString: sampleTrack.id), isTrue);
        final uuidRegex = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          caseSensitive: false,
        );
        expect(uuidRegex.hasMatch(sampleTrack.id), isTrue);

        // Verify stored row directly from Drift SQLite Table
        final rawRows = await db.select(db.favoritesTable).get();
        expect(rawRows.length, 1);
        expect(rawRows.first.id, sampleTrack.id);
        expect(uuidRegex.hasMatch(rawRows.first.id), isTrue);
        expect(rawRows.first.trackId, 'track-abc-123');
        expect(rawRows.first.title, 'Bohemian Rhapsody');
      },
    );

    test(
      'Auto-generated ID on dataSource.insertFavorite generates valid UUID v4',
      () async {
        await dataSource.insertFavorite(
          trackId: 'track-no-id-999',
          title: 'Imagine',
          artist: 'John Lennon',
          durationMs: 180000,
        );

        final rawRows = await db.select(db.favoritesTable).get();
        expect(rawRows.length, 1);
        final generatedId = rawRows.first.id;
        expect(Uuid.isValidUUID(fromString: generatedId), isTrue);
        final uuidRegex = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          caseSensitive: false,
        );
        expect(uuidRegex.hasMatch(generatedId), isTrue);
      },
    );

    test(
      'isFavorite returns true when track exists and false when removed',
      () async {
        expect(await repository.isFavorite('track-abc-123'), isFalse);

        await repository.addFavorite(sampleTrack);
        expect(await repository.isFavorite('track-abc-123'), isTrue);

        await repository.removeFavorite('track-abc-123');
        expect(await repository.isFavorite('track-abc-123'), isFalse);
      },
    );

    test(
      'toggleFavorite adds track when not present and removes when present',
      () async {
        await repository.toggleFavorite(sampleTrack);
        expect(await repository.isFavorite(sampleTrack.trackId), isTrue);

        await repository.toggleFavorite(sampleTrack);
        expect(await repository.isFavorite(sampleTrack.trackId), isFalse);
      },
    );

    test(
      'getFavorites returns all saved tracks ordered by addedAt desc',
      () async {
        final track2 = FavoriteTrack(
          id: uuid.v4(),
          trackId: 'track-xyz-789',
          title: 'Hotel California',
          artist: 'Eagles',
          album: 'Hotel California',
          duration: const Duration(minutes: 6, seconds: 30),
          audioUrl: '/storage/music/eagles.mp3',
          addedAt: DateTime.now().add(const Duration(seconds: 1)),
        );

        await repository.addFavorite(sampleTrack);
        await repository.addFavorite(track2);

        final all = await repository.getFavorites();
        expect(all.length, 2);
        expect(all.first.trackId, 'track-xyz-789');
        expect(all.last.trackId, 'track-abc-123');
      },
    );
  });
}
