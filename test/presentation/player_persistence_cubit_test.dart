import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/application/application.dart';
import 'package:media_player/domain/entities/last_session_context.dart';
import 'package:media_player/domain/entities/repeat_mode.dart';
import 'package:media_player/domain/entities/track.dart';
import 'package:media_player/domain/repositories/player_preferences_repository.dart';
import 'package:media_player/infrastructure/repositories/audio_player_repository_impl.dart';
import 'package:media_player/presentation/cubits/player/audio_player_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockPlayerPreferencesRepository extends Mock
    implements PlayerPreferencesRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AudioPlayerRepositoryImpl repository;
  late MockPlayerPreferencesRepository mockPreferences;
  AudioPlayerCubit? cubit;

  const sampleTrack = Track(
    id: 'track_1',
    title: 'Starry Night',
    artist: 'Antigravity Ensemble',
    album: 'Cosmic Dreams',
    duration: Duration(minutes: 3, seconds: 45),
  );

  setUpAll(() {
    registerFallbackValue(AudioRepeatMode.off);
    registerFallbackValue(sampleTrack);
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    repository = AudioPlayerRepositoryImpl();
    mockPreferences = MockPlayerPreferencesRepository();

    // Default mock behaviors
    when(() => mockPreferences.getRepeatMode())
        .thenAnswer((_) async => AudioRepeatMode.off);
    when(() => mockPreferences.isShuffleEnabled())
        .thenAnswer((_) async => false);
    when(() => mockPreferences.getLastTrack()).thenAnswer((_) async => null);
    when(() => mockPreferences.saveRepeatMode(any())).thenAnswer((_) async {});
    when(() => mockPreferences.saveShuffleEnabled(any()))
        .thenAnswer((_) async {});
    when(() => mockPreferences.saveLastTrack(any(), any(), any()))
        .thenAnswer((_) async {});
  });

  tearDown(() async {
    await cubit?.close();
    repository.dispose();
  });

  AudioPlayerCubit createCubit() {
    final c = AudioPlayerCubit(
      audioPlayerRepository: repository,
      playTrackUseCase: PlayTrackUseCase(repository),
      pauseTrackUseCase: PauseTrackUseCase(repository),
      resumeTrackUseCase: ResumeTrackUseCase(repository),
      seekTrackUseCase: SeekTrackUseCase(repository),
      nextTrackUseCase: NextTrackUseCase(repository),
      previousTrackUseCase: PreviousTrackUseCase(repository),
      getPlaylistsUseCase: GetPlaylistsUseCase(repository),
      getTracksUseCase: GetTracksUseCase(repository),
      toggleFavoriteUseCase: ToggleFavoriteUseCase(repository),
      toggleSelectUseCase: ToggleSelectUseCase(repository),
      preferencesRepository: mockPreferences,
      removeTrackUseCase: RemoveTrackUseCase(repository),
      removeTracksUseCase: RemoveTracksUseCase(repository),
      setRepeatModeUseCase: SetRepeatModeUseCase(repository),
      setShuffleModeUseCase: SetShuffleModeUseCase(repository),
    );
    cubit = c;
    return c;
  }

  group('AudioPlayerCubit - State Persistence & Session Restoration', () {
    test(
      'loadInitialData restores saved repeat mode and shuffle enabled',
      () async {
        when(() => mockPreferences.getRepeatMode())
            .thenAnswer((_) async => AudioRepeatMode.once);
        when(() => mockPreferences.isShuffleEnabled())
            .thenAnswer((_) async => true);

        final playerCubit = createCubit();
        await playerCubit.loadInitialData();

        expect(playerCubit.state.repeatMode, AudioRepeatMode.once);
        expect(playerCubit.state.isShuffleEnabled, isTrue);
      },
    );

    test(
      'loadInitialData restores last session track without autoplaying',
      () async {
        const lastSession = LastSessionContext(
          trackId: 'track_2',
          index: 1,
          position: Duration(minutes: 1, seconds: 20),
          title: 'Morning Flight',
          artist: 'Ambient Echoes',
          album: 'Sunrise Horizons',
          duration: Duration(minutes: 4, seconds: 10),
        );
        when(() => mockPreferences.getLastTrack())
            .thenAnswer((_) async => lastSession);

        final playerCubit = createCubit();
        await playerCubit.loadInitialData();

        // Must NOT auto-play
        expect(playerCubit.state.isPlaying, isFalse);
        expect(playerCubit.state.status, AudioPlayerStatus.paused);

        // Track metadata restored
        expect(playerCubit.state.currentTrack, isNotNull);
        expect(playerCubit.state.currentTrack!.id, 'track_2');
        expect(
          playerCubit.state.position,
          const Duration(minutes: 1, seconds: 20),
        );
        expect(
          playerCubit.state.duration,
          const Duration(minutes: 4, seconds: 10),
        );

        // Highlight and initial scroll index populated
        expect(playerCubit.state.highlightedTrackId, 'track_2');
        expect(playerCubit.state.initialScrollIndex, 1);
        expect(playerCubit.state.hasRestoredSession, isTrue);
      },
    );

    test('cycleRepeatMode persists next repeat mode to repository', () async {
      final playerCubit = createCubit();
      await playerCubit.loadInitialData();

      await playerCubit.cycleRepeatMode();
      expect(playerCubit.state.repeatMode, AudioRepeatMode.once);
      verify(() => mockPreferences.saveRepeatMode(AudioRepeatMode.once))
          .called(1);

      await playerCubit.cycleRepeatMode();
      expect(playerCubit.state.repeatMode, AudioRepeatMode.all);
      verify(() => mockPreferences.saveRepeatMode(AudioRepeatMode.all))
          .called(1);
    });

    test('setRepeatMode persists specified repeat mode', () async {
      final playerCubit = createCubit();
      await playerCubit.loadInitialData();

      await playerCubit.setRepeatMode(AudioRepeatMode.all);
      expect(playerCubit.state.repeatMode, AudioRepeatMode.all);
      verify(() => mockPreferences.saveRepeatMode(AudioRepeatMode.all))
          .called(1);
    });

    test('toggleShuffle persists updated shuffle flag', () async {
      final playerCubit = createCubit();
      await playerCubit.loadInitialData();

      await playerCubit.toggleShuffle();
      expect(playerCubit.state.isShuffleEnabled, isTrue);
      verify(() => mockPreferences.saveShuffleEnabled(true)).called(1);

      await playerCubit.toggleShuffle();
      expect(playerCubit.state.isShuffleEnabled, isFalse);
      verify(() => mockPreferences.saveShuffleEnabled(false)).called(1);
    });

    test('playTrack persists track immediately and highlights it', () async {
      final playerCubit = createCubit();
      await playerCubit.loadInitialData();

      await playerCubit.playTrack(sampleTrack);

      expect(playerCubit.state.currentTrack?.id, sampleTrack.id);
      expect(playerCubit.state.highlightedTrackId, sampleTrack.id);
      verify(
        () => mockPreferences.saveLastTrack(sampleTrack, any(), Duration.zero),
      ).called(1);
    });

    test('togglePlayPause persists playback position upon pause', () async {
      final playerCubit = createCubit();
      await playerCubit.loadInitialData();

      await playerCubit.playTrack(sampleTrack);
      await playerCubit.seek(const Duration(seconds: 45));

      // Pause playback
      await playerCubit.togglePlayPause();
      expect(playerCubit.state.isPlaying, isFalse);

      verify(
        () => mockPreferences.saveLastTrack(
          sampleTrack,
          any(),
          const Duration(seconds: 45),
        ),
      ).called(greaterThanOrEqualTo(1));
    });

    test('clearInitialScroll sets initialScrollIndex to null', () async {
      const lastSession = LastSessionContext(
        trackId: 'track_1',
        index: 0,
        position: Duration(seconds: 30),
      );
      when(() => mockPreferences.getLastTrack())
          .thenAnswer((_) async => lastSession);

      final playerCubit = createCubit();
      await playerCubit.loadInitialData();

      expect(playerCubit.state.initialScrollIndex, 0);

      playerCubit.clearInitialScroll();
      expect(playerCubit.state.initialScrollIndex, isNull);
    });
  });
}
