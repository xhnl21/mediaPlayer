import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/domain/entities/repeat_mode.dart';
import 'package:media_player/domain/entities/track.dart';
import 'package:media_player/infrastructure/datasources/secure_encrypted_data_source.dart';
import 'package:media_player/infrastructure/repositories/player_preferences_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureEncryptedDataSource extends Mock
    implements SecureEncryptedDataSource {}

void main() {
  late MockSecureEncryptedDataSource mockDataSource;
  late PlayerPreferencesRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockSecureEncryptedDataSource();
    repository = PlayerPreferencesRepositoryImpl(
      secureDataSource: mockDataSource,
    );
  });

  group('PlayerPreferencesRepositoryImpl - Repeat Mode', () {
    test('saveRepeatMode writes encrypted json with mode name', () async {
      when(
        () => mockDataSource.saveEncryptedJson(
          key: any(named: 'key'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async {});

      await repository.saveRepeatMode(AudioRepeatMode.once);

      verify(
        () => mockDataSource.saveEncryptedJson(
          key: 'PLAYER_PREF_REPEAT_MODE',
          data: {'mode': 'once'},
        ),
      ).called(1);
    });

    test('getRepeatMode returns saved mode when data exists', () async {
      when(
        () => mockDataSource.getEncryptedJson(key: 'PLAYER_PREF_REPEAT_MODE'),
      ).thenAnswer((_) async => {'mode': 'all'});

      final mode = await repository.getRepeatMode();
      expect(mode, AudioRepeatMode.all);
    });

    test(
      'getRepeatMode returns AudioRepeatMode.off if key is absent',
      () async {
        when(
          () => mockDataSource.getEncryptedJson(key: 'PLAYER_PREF_REPEAT_MODE'),
        ).thenAnswer((_) async => null);

        final mode = await repository.getRepeatMode();
        expect(mode, AudioRepeatMode.off);
      },
    );

    test('getRepeatMode returns AudioRepeatMode.off on exception', () async {
      when(
        () => mockDataSource.getEncryptedJson(key: 'PLAYER_PREF_REPEAT_MODE'),
      ).thenThrow(Exception('Decryption error'));

      final mode = await repository.getRepeatMode();
      expect(mode, AudioRepeatMode.off);
    });
  });

  group('PlayerPreferencesRepositoryImpl - Shuffle Mode', () {
    test('saveShuffleEnabled writes encrypted json with boolean', () async {
      when(
        () => mockDataSource.saveEncryptedJson(
          key: any(named: 'key'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async {});

      await repository.saveShuffleEnabled(true);

      verify(
        () => mockDataSource.saveEncryptedJson(
          key: 'PLAYER_PREF_SHUFFLE_MODE',
          data: {'enabled': true},
        ),
      ).called(1);
    });

    test('isShuffleEnabled returns true when persisted as true', () async {
      when(
        () => mockDataSource.getEncryptedJson(key: 'PLAYER_PREF_SHUFFLE_MODE'),
      ).thenAnswer((_) async => {'enabled': true});

      final result = await repository.isShuffleEnabled();
      expect(result, isTrue);
    });

    test('isShuffleEnabled returns false when key absent or null', () async {
      when(
        () => mockDataSource.getEncryptedJson(key: 'PLAYER_PREF_SHUFFLE_MODE'),
      ).thenAnswer((_) async => null);

      final result = await repository.isShuffleEnabled();
      expect(result, isFalse);
    });

    test('isShuffleEnabled returns false gracefully on error', () async {
      when(
        () => mockDataSource.getEncryptedJson(key: 'PLAYER_PREF_SHUFFLE_MODE'),
      ).thenThrow(Exception('Keystore locked'));

      final result = await repository.isShuffleEnabled();
      expect(result, isFalse);
    });
  });

  group('PlayerPreferencesRepositoryImpl - Last Session Track', () {
    const testTrack = Track(
      id: 'track_test_123',
      title: 'Bohemian Rhapsody',
      artist: 'Queen',
      album: 'A Night at the Opera',
      duration: Duration(minutes: 5, seconds: 55),
      audioUrl: '/storage/emulated/0/Music/bohemian.mp3',
    );

    test(
      'saveLastTrack writes full session snapshot to encrypted storage',
      () async {
        when(
          () => mockDataSource.saveEncryptedJson(
            key: any(named: 'key'),
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async {});

        await repository.saveLastTrack(
          testTrack,
          3,
          const Duration(minutes: 2, seconds: 15),
        );

        verify(
          () => mockDataSource.saveEncryptedJson(
            key: 'PLAYER_PREF_LAST_SESSION',
            data: {
              'trackId': 'track_test_123',
              'index': 3,
              'positionMs': 135000,
              'title': 'Bohemian Rhapsody',
              'artist': 'Queen',
              'album': 'A Night at the Opera',
              'audioUrl': '/storage/emulated/0/Music/bohemian.mp3',
              'durationMs': 355000,
            },
          ),
        ).called(1);
      },
    );

    test('getLastTrack returns reconstructed LastSessionContext', () async {
      when(
        () => mockDataSource.getEncryptedJson(key: 'PLAYER_PREF_LAST_SESSION'),
      ).thenAnswer(
        (_) async => {
          'trackId': 'track_test_123',
          'index': 3,
          'positionMs': 135000,
          'title': 'Bohemian Rhapsody',
          'artist': 'Queen',
          'album': 'A Night at the Opera',
          'audioUrl': '/storage/emulated/0/Music/bohemian.mp3',
          'durationMs': 355000,
        },
      );

      final session = await repository.getLastTrack();
      expect(session, isNotNull);
      expect(session!.trackId, 'track_test_123');
      expect(session.index, 3);
      expect(session.position, const Duration(minutes: 2, seconds: 15));
      expect(session.title, 'Bohemian Rhapsody');
      expect(session.artist, 'Queen');
      expect(session.album, 'A Night at the Opera');
      expect(session.duration, const Duration(minutes: 5, seconds: 55));
    });

    test(
      'getLastTrack returns null safely when no prior session exists',
      () async {
        when(
          () =>
              mockDataSource.getEncryptedJson(key: 'PLAYER_PREF_LAST_SESSION'),
        ).thenAnswer((_) async => null);

        final session = await repository.getLastTrack();
        expect(session, isNull);
      },
    );

    test(
      'getLastTrack handles decryption failure gracefully without crashing',
      () async {
        when(
          () =>
              mockDataSource.getEncryptedJson(key: 'PLAYER_PREF_LAST_SESSION'),
        ).thenThrow(Exception('Corrupt AES payload'));

        final session = await repository.getLastTrack();
        expect(session, isNull);
      },
    );
  });
}
