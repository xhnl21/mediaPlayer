import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:media_player/domain/entities/repeat_mode.dart';
import 'package:media_player/domain/entities/track.dart';
import 'package:media_player/infrastructure/repositories/audio_player_repository_impl.dart';
import 'package:media_player/infrastructure/services/audio_player_handler.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAudioPlayer mockPlayer;
  late AudioPlayerHandlerImpl handler;

  const testTrack1 = Track(
    id: 'track_bg_1',
    title: 'Background Symphony No. 5',
    artist: 'Ludwig van Beethoven',
    album: 'Classical Immortals',
    duration: Duration(minutes: 7, seconds: 20),
    coverUrl: 'https://images.example.com/beethoven.jpg',
  );

  const testTrack2 = Track(
    id: 'track_bg_2',
    title: 'Moonlight Sonata',
    artist: 'Ludwig van Beethoven',
    album: 'Classical Immortals',
    duration: Duration(minutes: 5, seconds: 12),
  );

  setUpAll(() {
    registerFallbackValue(LoopMode.off);
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    mockPlayer = MockAudioPlayer();

    when(
      () => mockPlayer.playerStateStream,
    ).thenAnswer((_) => Stream.value(PlayerState(false, ProcessingState.idle)));
    when(() => mockPlayer.positionStream)
        .thenAnswer((_) => Stream.value(Duration.zero));
    when(() => mockPlayer.durationStream)
        .thenAnswer((_) => Stream.value(Duration.zero));
    when(() => mockPlayer.playbackEventStream)
        .thenAnswer((_) => Stream.value(PlaybackEvent()));
    when(() => mockPlayer.playerState)
        .thenReturn(PlayerState(false, ProcessingState.idle));
    when(() => mockPlayer.position).thenReturn(Duration.zero);
    when(() => mockPlayer.bufferedPosition).thenReturn(Duration.zero);
    when(() => mockPlayer.speed).thenReturn(1.0);
    when(() => mockPlayer.volume).thenReturn(1.0);
    when(() => mockPlayer.setLoopMode(any())).thenAnswer((_) async {});
    when(() => mockPlayer.play()).thenAnswer((_) async {});
    when(() => mockPlayer.pause()).thenAnswer((_) async {});
    when(() => mockPlayer.seek(any())).thenAnswer((_) async {});
    when(() => mockPlayer.stop()).thenAnswer((_) async {});
    when(() => mockPlayer.dispose()).thenAnswer((_) async {});

    handler = AudioPlayerHandlerImpl(player: mockPlayer);
  });

  tearDown(() async {
    await handler.dispose();
  });

  group('AudioPlayerHandlerImpl Background Service & Lock Screen Tests', () {
    test('playTrack updates mediaItem stream with domain metadata', () async {
      await handler.playTrack(testTrack1);

      final item = handler.mediaItem.value;
      expect(item, isNotNull);
      expect(item!.id, 'track_bg_1');
      expect(item.title, 'Background Symphony No. 5');
      expect(item.artist, 'Ludwig van Beethoven');
      expect(item.album, 'Classical Immortals');
      expect(item.duration, const Duration(minutes: 7, seconds: 20));
      expect(
        item.artUri,
        Uri.parse('https://images.example.com/beethoven.jpg'),
      );
    });

    test('playbackState exposes correct Android compact action indices and controls', () async {
      await handler.playTrack(testTrack1);

      final state = handler.playbackState.value;
      expect(state.androidCompactActionIndices, const [0, 1, 2]);
      expect(state.controls, contains(MediaControl.skipToPrevious));
      expect(state.controls, contains(MediaControl.skipToNext));
      expect(state.controls, contains(MediaControl.stop));
    });

    test('remote lock screen callbacks (skipToNext, skipToPrevious) trigger handler delegates', () async {
      var nextCalled = false;
      var prevCalled = false;

      handler.onSkipToNextRequested = () => nextCalled = true;
      handler.onSkipToPreviousRequested = () => prevCalled = true;

      await handler.skipToNext();
      expect(nextCalled, isTrue);

      await handler.skipToPrevious();
      expect(prevCalled, isTrue);
    });

    test('repeatMode updates PlaybackState.repeatMode', () async {
      await handler.setAudioRepeatMode(AudioRepeatMode.all);
      expect(
        handler.playbackState.value.repeatMode,
        AudioServiceRepeatMode.all,
      );
      verify(() => mockPlayer.setLoopMode(LoopMode.one)).called(1);

      await handler.setAudioRepeatMode(AudioRepeatMode.once);
      expect(
        handler.playbackState.value.repeatMode,
        AudioServiceRepeatMode.one,
      );

      await handler.setAudioRepeatMode(AudioRepeatMode.off);
      expect(
        handler.playbackState.value.repeatMode,
        AudioServiceRepeatMode.none,
      );
    });

    test('shuffle updates PlaybackState.shuffleMode', () {
      handler.setShuffle(true);
      expect(
        handler.playbackState.value.shuffleMode,
        AudioServiceShuffleMode.all,
      );

      handler.setShuffle(false);
      expect(
        handler.playbackState.value.shuffleMode,
        AudioServiceShuffleMode.none,
      );
    });
  });

  group(
    'AudioPlayerRepositoryImpl & AudioPlayerHandlerImpl Integration Tests',
    () {
      test('Repository delegates play to handler and remote skip controls trigger repository navigation', () async {
        final repository = AudioPlayerRepositoryImpl(
          audioHandler: handler,
          initialTracks: [testTrack1, testTrack2],
        );

        // 1. Play track 1
        await repository.play(testTrack1);
        expect(handler.mediaItem.value?.id, testTrack1.id);
        expect(repository.currentTrack?.id, testTrack1.id);

        // 2. Simulate remote skip to next from lock screen
        await handler.skipToNext();
        expect(repository.currentTrack?.id, testTrack2.id);
        expect(handler.mediaItem.value?.id, testTrack2.id);

        // 3. Simulate remote skip to previous from lock screen
        await handler.skipToPrevious();
        expect(repository.currentTrack?.id, testTrack1.id);
        expect(handler.mediaItem.value?.id, testTrack1.id);

        repository.dispose();
      });
    },
  );
}
