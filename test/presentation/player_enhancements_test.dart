import 'dart:io';

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

    test('repository repeatModeStream emits updates that update cubit state reactively', () async {
      expect(cubit.state.repeatMode, AudioRepeatMode.off);

      await repository.setRepeatMode(AudioRepeatMode.all);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.repeatMode, AudioRepeatMode.all);

      await repository.setRepeatMode(AudioRepeatMode.once);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.repeatMode, AudioRepeatMode.once);

      await repository.setRepeatMode(AudioRepeatMode.off);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.repeatMode, AudioRepeatMode.off);
    });
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

      await cubit.removeTrack(trackToRemove.id, deleteFromDevice: false);

      expect(cubit.state.tracks.length, initialCount - 1);
      expect(cubit.state.tracks.any((t) => t.id == trackToRemove.id), isFalse);
    });

    test('removeTrack with deleteFromDevice: true removes track and deletes physical file from storage', () async {
      // Create a temporary file on disk
      final tempDir = Directory.systemTemp.createTempSync('player_test_');
      final tempFile = File('${tempDir.path}/test_audio_track.mp3');
      await tempFile.writeAsString('dummy mp3 content');
      expect(await tempFile.exists(), isTrue);

      final testTrack = Track(
        id: 'temp-physical-track-1',
        title: 'Physical Test Track',
        artist: 'Tester',
        duration: const Duration(minutes: 1),
        audioUrl: tempFile.path,
      );

      final customRepo = AudioPlayerRepositoryImpl(
        initialTracks: [testTrack, ...cubit.state.tracks],
      );
      final customCubit = AudioPlayerCubit(
        audioPlayerRepository: customRepo,
        playTrackUseCase: PlayTrackUseCase(customRepo),
        pauseTrackUseCase: PauseTrackUseCase(customRepo),
        resumeTrackUseCase: ResumeTrackUseCase(customRepo),
        seekTrackUseCase: SeekTrackUseCase(customRepo),
        nextTrackUseCase: NextTrackUseCase(customRepo),
        previousTrackUseCase: PreviousTrackUseCase(customRepo),
        getPlaylistsUseCase: GetPlaylistsUseCase(customRepo),
        getTracksUseCase: GetTracksUseCase(customRepo),
        toggleFavoriteUseCase: ToggleFavoriteUseCase(customRepo),
        toggleSelectUseCase: ToggleSelectUseCase(customRepo),
        removeTrackUseCase: RemoveTrackUseCase(customRepo),
        removeTracksUseCase: RemoveTracksUseCase(customRepo),
        setRepeatModeUseCase: SetRepeatModeUseCase(customRepo),
        setShuffleModeUseCase: SetShuffleModeUseCase(customRepo),
      );
      await customCubit.loadInitialData();

      expect(customCubit.state.tracks.any((t) => t.id == testTrack.id), isTrue);

      // Delete with deleteFromDevice: true
      await customCubit.removeTrack(testTrack.id, deleteFromDevice: true);

      expect(
        customCubit.state.tracks.any((t) => t.id == testTrack.id),
        isFalse,
      );
      expect(await tempFile.exists(), isFalse);

      await customCubit.close();
      customRepo.dispose();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
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

        await cubit.removeSelectedTracks(deleteFromDevice: false);

        expect(cubit.state.tracks.length, initialCount - 2);
        expect(cubit.state.selectedTrackIds, isEmpty);
        expect(cubit.state.isSelectionMode, isFalse);
        expect(cubit.state.tracks.any((t) => t.id == firstTrackId), isFalse);
        expect(cubit.state.tracks.any((t) => t.id == secondTrackId), isFalse);
      },
    );

    test('removeSelectedTracks with deleteFromDevice: true deletes all selected physical files from storage', () async {
      final tempDir = Directory.systemTemp.createTempSync('player_batch_test_');
      final tempFile1 = File('${tempDir.path}/batch_track_1.mp3');
      final tempFile2 = File('${tempDir.path}/batch_track_2.mp3');
      await tempFile1.writeAsString('batch content 1');
      await tempFile2.writeAsString('batch content 2');
      expect(await tempFile1.exists(), isTrue);
      expect(await tempFile2.exists(), isTrue);

      final track1 = Track(
        id: 'batch-track-1',
        title: 'Batch 1',
        artist: 'Tester',
        duration: const Duration(minutes: 1),
        audioUrl: tempFile1.path,
      );
      final track2 = Track(
        id: 'batch-track-2',
        title: 'Batch 2',
        artist: 'Tester',
        duration: const Duration(minutes: 2),
        audioUrl: tempFile2.path,
      );

      final customRepo = AudioPlayerRepositoryImpl(
        initialTracks: [track1, track2, ...cubit.state.tracks],
      );
      final customCubit = AudioPlayerCubit(
        audioPlayerRepository: customRepo,
        playTrackUseCase: PlayTrackUseCase(customRepo),
        pauseTrackUseCase: PauseTrackUseCase(customRepo),
        resumeTrackUseCase: ResumeTrackUseCase(customRepo),
        seekTrackUseCase: SeekTrackUseCase(customRepo),
        nextTrackUseCase: NextTrackUseCase(customRepo),
        previousTrackUseCase: PreviousTrackUseCase(customRepo),
        getPlaylistsUseCase: GetPlaylistsUseCase(customRepo),
        getTracksUseCase: GetTracksUseCase(customRepo),
        toggleFavoriteUseCase: ToggleFavoriteUseCase(customRepo),
        toggleSelectUseCase: ToggleSelectUseCase(customRepo),
        removeTrackUseCase: RemoveTrackUseCase(customRepo),
        removeTracksUseCase: RemoveTracksUseCase(customRepo),
        setRepeatModeUseCase: SetRepeatModeUseCase(customRepo),
        setShuffleModeUseCase: SetShuffleModeUseCase(customRepo),
      );
      await customCubit.loadInitialData();

      customCubit.toggleSelectionMode(true);
      await customCubit.toggleSelect(track1.id);
      await customCubit.toggleSelect(track2.id);
      expect(customCubit.state.selectedTrackIds.length, 2);

      await customCubit.removeSelectedTracks(deleteFromDevice: true);

      expect(await tempFile1.exists(), isFalse);
      expect(await tempFile2.exists(), isFalse);
      expect(customCubit.state.tracks.any((t) => t.id == track1.id), isFalse);
      expect(customCubit.state.tracks.any((t) => t.id == track2.id), isFalse);

      await customCubit.close();
      customRepo.dispose();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
  });
}
