import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/application/application.dart';
import 'package:media_player/domain/player.dart';
import 'package:media_player/infrastructure/datasources/database/app_database.dart';
import 'package:media_player/infrastructure/datasources/database/drift_favorites_data_source.dart';
import 'package:media_player/infrastructure/repositories/audio_player_repository_impl.dart';
import 'package:media_player/infrastructure/repositories/favorites_repository_impl.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/screens/playlist_tracks_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  late AudioPlayerRepositoryImpl playerRepo;
  late AppDatabase db;
  late DriftFavoritesDataSourceImpl favDataSource;
  late FavoritesRepositoryImpl favRepo;
  late NavigationCubit navCubit;
  late AudioPlayerCubit playerCubit;
  late FavoritesCubit favCubit;

  setUp(() async {
    playerRepo = AudioPlayerRepositoryImpl();
    db = AppDatabase(NativeDatabase.memory());
    favDataSource = DriftFavoritesDataSourceImpl(db);
    favRepo = FavoritesRepositoryImpl(dataSource: favDataSource);

    navCubit = NavigationCubit();
    playerCubit = AudioPlayerCubit(
      audioPlayerRepository: playerRepo,
      playTrackUseCase: PlayTrackUseCase(playerRepo),
      pauseTrackUseCase: PauseTrackUseCase(playerRepo),
      resumeTrackUseCase: ResumeTrackUseCase(playerRepo),
      seekTrackUseCase: SeekTrackUseCase(playerRepo),
      nextTrackUseCase: NextTrackUseCase(playerRepo),
      previousTrackUseCase: PreviousTrackUseCase(playerRepo),
      getPlaylistsUseCase: GetPlaylistsUseCase(playerRepo),
      getTracksUseCase: GetTracksUseCase(playerRepo),
      toggleFavoriteUseCase: ToggleFavoriteUseCase(playerRepo),
      toggleSelectUseCase: ToggleSelectUseCase(playerRepo),
      removeTrackUseCase: RemoveTrackUseCase(playerRepo),
      removeTracksUseCase: RemoveTracksUseCase(playerRepo),
      setRepeatModeUseCase: SetRepeatModeUseCase(playerRepo),
      setShuffleModeUseCase: SetShuffleModeUseCase(playerRepo),
    );
    favCubit = FavoritesCubit(
      getFavoritesUseCase: GetFavoritesUseCase(favRepo),
      toggleFavoriteTrackUseCase: ToggleFavoriteTrackUseCase(favRepo),
      removeFavoriteTrackUseCase: RemoveFavoriteTrackUseCase(favRepo),
      favoritesRepository: favRepo,
    );

    await playerCubit.loadInitialData();
  });

  tearDown(() async {
    await playerCubit.close();
    await favCubit.close();
    await navCubit.close();
    playerRepo.dispose();
    favRepo.dispose();
    await db.close();
  });

  Widget createTestWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationCubit>.value(value: navCubit),
        BlocProvider<AudioPlayerCubit>.value(value: playerCubit),
        BlocProvider<FavoritesCubit>.value(value: favCubit),
      ],
      child: const MaterialApp(home: PlaylistTracksScreen()),
    );
  }

  group('PlaylistTracksScreen Widget & Interaction Tests', () {
    testWidgets('Cart icon is completely removed from view', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shopping_cart), findsNothing);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsNothing);
      expect(find.byIcon(Icons.shopping_bag), findsNothing);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsNothing);
      expect(find.textContaining('Cart'), findsNothing);
    });

    testWidgets('Repeat and Shuffle controls exist and respond to taps', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify Shuffle button exists
      final shuffleButton = find.byIcon(Icons.shuffle_rounded);
      expect(shuffleButton, findsWidgets);

      // Tap Shuffle button
      await tester.tap(shuffleButton.first);
      await tester.pumpAndSettle();
      expect(playerCubit.state.isShuffleEnabled, isTrue);

      // Verify Repeat button exists
      final repeatButton = find.byIcon(Icons.repeat_rounded);
      expect(repeatButton, findsWidgets);

      // Tap Repeat button to cycle mode
      await tester.tap(repeatButton.first);
      await tester.pumpAndSettle();
      expect(playerCubit.state.repeatMode, AudioRepeatMode.once);
    });

    testWidgets('Filter tabs switch between All Tracks and Favorites view', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('All ('), findsOneWidget);
      expect(find.textContaining('Favorites ('), findsOneWidget);

      // Tap Favorites tab
      await tester.tap(find.textContaining('Favorites ('));
      await tester.pumpAndSettle();

      // Expect empty favorites state
      expect(find.text('No favorites yet'), findsOneWidget);

      // Tap back to All Tracks tab
      await tester.tap(find.textContaining('All ('));
      await tester.pumpAndSettle();

      expect(find.text('No favorites yet'), findsNothing);
    });

    testWidgets(
      'Tapping delete icon shows delete options dialog and CANCEL dismisses it',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final deleteIcons = find.byIcon(Icons.delete_outline_rounded);
        expect(deleteIcons, findsWidgets);

        // Tap delete on first track item
        await tester.tap(deleteIcons.first);
        await tester.pumpAndSettle();

        // Verify options dialog appeared
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Delete Track'), findsOneWidget);
        expect(
          find.text('Where would you like to delete this from?'),
          findsOneWidget,
        );
        expect(find.text('Remove from Playlist Only'), findsOneWidget);
        expect(find.text('Delete from Device & Playlist'), findsOneWidget);
        expect(find.text('CANCEL'), findsOneWidget);

        // Tap CANCEL
        await tester.tap(find.text('CANCEL'));
        await tester.pumpAndSettle();

        // Dialog dismissed
        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    testWidgets(
      'Selecting "Remove from Playlist Only" removes track from memory',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final initialCount = playerCubit.state.tracks.length;
        final firstTrackId = playerCubit.state.tracks.first.id;

        final deleteIcons = find.byIcon(Icons.delete_outline_rounded);
        await tester.tap(deleteIcons.first);
        await tester.pumpAndSettle();

        // Tap Remove from Playlist Only
        await tester.tap(find.text('Remove from Playlist Only'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(playerCubit.state.tracks.length, initialCount - 1);
        expect(
          playerCubit.state.tracks.any((t) => t.id == firstTrackId),
          isFalse,
        );
      },
    );

    testWidgets(
      'Selecting "Delete from Device & Playlist" removes track from playlist and device',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final initialCount = playerCubit.state.tracks.length;
        final firstTrackId = playerCubit.state.tracks.first.id;

        final deleteIcons = find.byIcon(Icons.delete_outline_rounded);
        await tester.tap(deleteIcons.first);
        await tester.pumpAndSettle();

        // Tap Delete from Device & Playlist
        await tester.tap(find.text('Delete from Device & Playlist'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(playerCubit.state.tracks.length, initialCount - 1);
        expect(
          playerCubit.state.tracks.any((t) => t.id == firstTrackId),
          isFalse,
        );
      },
    );

    testWidgets(
      'Batch delete displays options dialog and removes selected tracks',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final initialCount = playerCubit.state.tracks.length;
        final firstId = playerCubit.state.tracks[0].id;
        final secondId = playerCubit.state.tracks[1].id;

        // Activate selection mode and select 2 tracks
        playerCubit.toggleSelectionMode(true);
        await playerCubit.toggleSelect(firstId);
        await playerCubit.toggleSelect(secondId);
        await tester.pumpAndSettle();

        // Expect Delete (2) button in AppBar
        final batchDeleteButton = find.text('Delete (2)');
        expect(batchDeleteButton, findsOneWidget);

        await tester.tap(batchDeleteButton);
        await tester.pumpAndSettle();

        // Verify batch dialog options
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Delete Multiple Tracks'), findsOneWidget);
        expect(find.text('2 tracks selected'), findsOneWidget);
        expect(find.text('Remove from Playlist Only'), findsOneWidget);
        expect(find.text('Delete from Device & Playlist'), findsOneWidget);

        // Tap Delete from Device & Playlist
        await tester.tap(find.text('Delete from Device & Playlist'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(playerCubit.state.tracks.length, initialCount - 2);
        expect(playerCubit.state.tracks.any((t) => t.id == firstId), isFalse);
        expect(playerCubit.state.tracks.any((t) => t.id == secondId), isFalse);
        expect(playerCubit.state.isSelectionMode, isFalse);
      },
    );
  });
}
