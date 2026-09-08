import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/application/application.dart';
import 'package:media_player/domain/entities/track.dart';
import 'package:media_player/infrastructure/datasources/database/app_database.dart';
import 'package:media_player/infrastructure/datasources/database/drift_favorites_data_source.dart';
import 'package:media_player/infrastructure/repositories/favorites_repository_impl.dart';
import 'package:media_player/presentation/cubits/favorites/favorites_cubit.dart';

void main() {
  late AppDatabase db;
  late DriftFavoritesDataSourceImpl dataSource;
  late FavoritesRepositoryImpl repository;
  late FavoritesCubit cubit;

  const sampleTrack = Track(
    id: 'track-001',
    title: 'Comfortably Numb',
    artist: 'Pink Floyd',
    album: 'The Wall',
    duration: Duration(minutes: 6, seconds: 22),
    audioUrl: '/storage/music/pink_floyd.mp3',
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dataSource = DriftFavoritesDataSourceImpl(db);
    repository = FavoritesRepositoryImpl(dataSource: dataSource);
    cubit = FavoritesCubit(
      getFavoritesUseCase: GetFavoritesUseCase(repository),
      toggleFavoriteTrackUseCase: ToggleFavoriteTrackUseCase(repository),
      removeFavoriteTrackUseCase: RemoveFavoriteTrackUseCase(repository),
      favoritesRepository: repository,
    );
  });

  tearDown(() async {
    await cubit.close();
    repository.dispose();
    await db.close();
  });

  group('FavoritesCubit Presentation Tests', () {
    test('Initial state has empty favorites and finishes loading', () async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.favorites, isEmpty);
      expect(cubit.state.favoriteTrackIds, isEmpty);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
    });

    test(
      'toggleFavorite adds track to favorites and updates state reactively',
      () async {
        await cubit.toggleFavorite(sampleTrack);

        expect(cubit.state.favorites.length, 1);
        expect(cubit.state.isFavorite(sampleTrack.id), isTrue);
        expect(cubit.state.favorites.first.trackId, sampleTrack.id);
        expect(cubit.state.favorites.first.title, sampleTrack.title);
      },
    );

    test('toggleFavorite removes track when called twice', () async {
      await cubit.toggleFavorite(sampleTrack);
      expect(cubit.state.isFavorite(sampleTrack.id), isTrue);

      await cubit.toggleFavorite(sampleTrack);
      expect(cubit.state.isFavorite(sampleTrack.id), isFalse);
      expect(cubit.state.favorites, isEmpty);
    });

    test('removeFavorite removes track from favorites state', () async {
      await cubit.toggleFavorite(sampleTrack);
      expect(cubit.state.isFavorite(sampleTrack.id), isTrue);

      await cubit.removeFavorite(sampleTrack.id);
      expect(cubit.state.isFavorite(sampleTrack.id), isFalse);
      expect(cubit.state.favorites, isEmpty);
    });
  });
}
