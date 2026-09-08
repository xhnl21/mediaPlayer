import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/application/application.dart';
import 'package:media_player/domain/player.dart';
import 'package:media_player/infrastructure/repositories/audio_player_repository_impl.dart';
import 'package:media_player/presentation/cubits/player/audio_player_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AudioPlayerRepositoryImpl repository;
  late AudioPlayerCubit cubit;

  setUp(() async {
    repository = AudioPlayerRepositoryImpl();
    cubit = AudioPlayerCubit(
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
      removeTrackUseCase: RemoveTrackUseCase(repository),
      removeTracksUseCase: RemoveTracksUseCase(repository),
      setRepeatModeUseCase: SetRepeatModeUseCase(repository),
      setShuffleModeUseCase: SetShuffleModeUseCase(repository),
    );
    await cubit.loadInitialData();
  });

  tearDown(() async {
    await cubit.close();
    repository.dispose();
  });

  group('AudioPlayerCubit Enhancements - Repeat Mode Tests', () {
    test('Initial repeat mode is AudioRepeatMode.off', () {
      expect(cubit.state.repeatMode, AudioRepeatMode.off);
    });

    test(
      'cycleRepeatMode transitions correctly: off -> once -> all -> off',
      () async {
        expect(cubit.state.repeatMode, AudioRepeatMode.off);

        await cubit.cycleRepeatMode();
        expect(cubit.state.repeatMode, AudioRepeatMode.once);

        await cubit.cycleRepeatMode();
        expect(cubit.state.repeatMode, AudioRepeatMode.all);

        await cubit.cycleRepeatMode();
        expect(cubit.state.repeatMode, AudioRepeatMode.off);
      },
    );

    test(
      'setRepeatMode sets specific repeat mode and updates repository',
      () async {
        await cubit.setRepeatMode(AudioRepeatMode.all);
        expect(cubit.state.repeatMode, AudioRepeatMode.all);

        await cubit.setRepeatMode(AudioRepeatMode.once);
        expect(cubit.state.repeatMode, AudioRepeatMode.once);
      },
    );
  });

  group('AudioPlayerCubit Enhancements - Shuffle Mode Tests', () {
    test('Initial shuffle state is disabled', () {
      expect(cubit.state.isShuffleEnabled, isFalse);
    });

    test('toggleShuffle enables and disables shuffle reactively', () async {
      await cubit.toggleShuffle();
      expect(cubit.state.isShuffleEnabled, isTrue);

      await cubit.toggleShuffle();
      expect(cubit.state.isShuffleEnabled, isFalse);
    });
  });

  group('AudioPlayerCubit Enhancements - Selection & Deletion Tests', () {
    test('toggleSelectionMode enables and disables selection mode and clears selection on exit', () async {
      expect(cubit.state.isSelectionMode, isFalse);

      cubit.toggleSelectionMode(true);
      expect(cubit.state.isSelectionMode, isTrue);

      final trackId = cubit.state.tracks.first.id;
      await cubit.toggleSelect(trackId);
      expect(cubit.state.selectedTrackIds, contains(trackId));

      cubit.toggleSelectionMode(false);
      expect(cubit.state.isSelectionMode, isFalse);
      expect(cubit.state.selectedTrackIds, isEmpty);
    });

    test('selectAllTracks selects all tracks and clearSelection resets it', () {
      cubit.toggleSelectionMode(true);
      cubit.selectAllTracks();

      expect(cubit.state.selectedTrackIds.length, cubit.state.tracks.length);
      for (final t in cubit.state.tracks) {
        expect(cubit.state.isTrackSelected(t.id), isTrue);
      }

      cubit.clearSelection();
      expect(cubit.state.selectedTrackIds, isEmpty);
    });

    test('removeTrack removes single track from in-memory playlist without deleting file from device', () async {
      final initialCount = cubit.state.tracks.length;
      expect(initialCount, greaterThan(1));
      final trackToRemove = cubit.state.tracks.first;

      await cubit.removeTrack(trackToRemove.id);

      expect(cubit.state.tracks.length, initialCount - 1);
      expect(cubit.state.tracks.any((t) => t.id == trackToRemove.id), isFalse);
    });

    test(
      'removeSelectedTracks removes all selected tracks and clears selection',
      () async {
        final initialCount = cubit.state.tracks.length;
        expect(initialCount, greaterThanOrEqualTo(2));

        final firstTrackId = cubit.state.tracks[0].id;
        final secondTrackId = cubit.state.tracks[1].id;

        cubit.toggleSelectionMode(true);
        await cubit.toggleSelect(firstTrackId);
        await cubit.toggleSelect(secondTrackId);
        expect(cubit.state.selectedTrackIds.length, 2);

        await cubit.removeSelectedTracks();

        expect(cubit.state.tracks.length, initialCount - 2);
        expect(cubit.state.selectedTrackIds, isEmpty);
        expect(cubit.state.isSelectionMode, isFalse);
        expect(cubit.state.tracks.any((t) => t.id == firstTrackId), isFalse);
        expect(cubit.state.tracks.any((t) => t.id == secondTrackId), isFalse);
      },
    );
  });
}
