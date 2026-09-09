import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/application/player.dart';
import 'package:media_player/domain/entities/track.dart';
import 'package:media_player/domain/repositories/audio_player_repository.dart';
import 'package:media_player/infrastructure/datasources/local_audio_data_source.dart';
import 'package:media_player/infrastructure/repositories/audio_player_repository_impl.dart';
import 'package:media_player/presentation/cubits/player/audio_player_cubit.dart';

class MockLocalAudioDataSource implements LocalAudioDataSource {
  MockLocalAudioDataSource({
    this.hasPermission = true,
    this.tracksToReturn = const [],
  });

  bool hasPermission;
  List<Track> tracksToReturn;

  @override
  Future<bool> checkPermissions() async => hasPermission;

  @override
  Future<bool> requestPermissions() async => hasPermission;

  @override
  Future<List<Track>> queryTracks() async => tracksToReturn;

  final List<String> deletedAudioUrls = [];

  @override
  Future<bool> deletePhysicalTrack({
    required String audioUrl,
    required String trackId,
  }) async {
    deletedAudioUrls.add(audioUrl);
    return true;
  }

  @override
  Future<bool> deletePhysicalTracks(List<Track> tracks) async {
    deletedAudioUrls.addAll(tracks.map((t) => t.audioUrl));
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Local Audio Repository & Scanning Tests', () {
    test(
      'scanLocalTracks loads tracks from LocalAudioDataSource into repository',
      () async {
        const sampleTrack = Track(
          id: 'local_1',
          title: 'Local Audio Track 1',
          artist: 'Sample Artist',
          album: 'Sample Album',
          duration: Duration(minutes: 3, seconds: 12),
          audioUrl: '/storage/emulated/0/Music/sample.mp3',
        );

        final mockDataSource = MockLocalAudioDataSource(
          hasPermission: true,
          tracksToReturn: [sampleTrack],
        );

        final repo = AudioPlayerRepositoryImpl(
          localAudioDataSource: mockDataSource,
        );

        final tracks = await repo.scanLocalTracks();
        expect(tracks.length, 1);
        expect(tracks.first.id, 'local_1');
        expect(tracks.first.title, 'Local Audio Track 1');
        expect(tracks.first.album, 'Sample Album');

        repo.dispose();
      },
    );

    test(
      'AudioPlayerRepositoryImpl delegates permission checks to data source',
      () async {
        final mockDataSource = MockLocalAudioDataSource(hasPermission: true);
        final repo = AudioPlayerRepositoryImpl(
          localAudioDataSource: mockDataSource,
        );

        expect(await repo.checkPermissions(), isTrue);
        expect(await repo.requestPermissions(), isTrue);

        mockDataSource.hasPermission = false;
        expect(await repo.checkPermissions(), isFalse);
        expect(await repo.requestPermissions(), isFalse);

        repo.dispose();
      },
    );

    test('AudioPlayerRepositoryImpl delegates physical deletion to LocalAudioDataSource', () async {
      const sampleTrack = Track(
        id: 'del_local_1',
        title: 'Delete Test Track',
        artist: 'Sample Artist',
        duration: Duration(minutes: 3),
        audioUrl: '/storage/emulated/0/Music/to_delete.mp3',
      );

      final mockDataSource = MockLocalAudioDataSource(
        hasPermission: true,
        tracksToReturn: [sampleTrack],
      );
      final repo = AudioPlayerRepositoryImpl(
        localAudioDataSource: mockDataSource,
        initialTracks: [sampleTrack],
      );

      expect(mockDataSource.deletedAudioUrls, isEmpty);

      await repo.removeTrack(sampleTrack.id, deleteFromDevice: true);

      expect(mockDataSource.deletedAudioUrls, contains(sampleTrack.audioUrl));
      final remaining = await repo.getTracks();
      expect(remaining.any((t) => t.id == sampleTrack.id), isFalse);

      repo.dispose();
    });

    test('AudioPlayerRepositoryImpl delegates batch physical deletion to LocalAudioDataSource in a single call', () async {
      const track1 = Track(
        id: 'batch_1',
        title: 'Batch 1',
        artist: 'Artist 1',
        duration: Duration(minutes: 2),
        audioUrl: '/storage/music/track1.mp3',
      );
      const track2 = Track(
        id: 'batch_2',
        title: 'Batch 2',
        artist: 'Artist 2',
        duration: Duration(minutes: 3),
        audioUrl: '/storage/music/track2.mp3',
      );

      final mockDataSource = MockLocalAudioDataSource(
        hasPermission: true,
        tracksToReturn: [track1, track2],
      );
      final repo = AudioPlayerRepositoryImpl(
        localAudioDataSource: mockDataSource,
        initialTracks: [track1, track2],
      );

      expect(mockDataSource.deletedAudioUrls, isEmpty);

      await repo.removeTracks([track1.id, track2.id], deleteFromDevice: true);

      expect(mockDataSource.deletedAudioUrls, contains(track1.audioUrl));
      expect(mockDataSource.deletedAudioUrls, contains(track2.audioUrl));
      final remaining = await repo.getTracks();
      expect(remaining, isEmpty);

      repo.dispose();
    });

    test('searchTracks finds tracks by title, artist, or album', () async {
      const sampleTrack = Track(
        id: 'local_search',
        title: 'Bohemian Rhapsody',
        artist: 'Queen',
        album: 'A Night at the Opera',
        duration: Duration(minutes: 5, seconds: 55),
        audioUrl: '/storage/music/bohemian.mp3',
      );

      final mockDataSource = MockLocalAudioDataSource(
        hasPermission: true,
        tracksToReturn: [sampleTrack],
      );

      final repo = AudioPlayerRepositoryImpl(
        localAudioDataSource: mockDataSource,
      );
      await repo.scanLocalTracks();

      final byTitle = await repo.searchTracks('Bohemian');
      expect(byTitle, isNotEmpty);
      expect(byTitle.first.title, 'Bohemian Rhapsody');

      final byArtist = await repo.searchTracks('Queen');
      expect(byArtist, isNotEmpty);

      final byAlbum = await repo.searchTracks('Opera');
      expect(byAlbum, isNotEmpty);

      repo.dispose();
    });
  });

  group('AudioPlayerCubit Local Scanning and Permissions Lifecycle', () {
    late AudioPlayerRepository repo;
    late MockLocalAudioDataSource mockDataSource;
    late AudioPlayerCubit cubit;

    setUp(() {
      mockDataSource = MockLocalAudioDataSource(
        hasPermission: false,
        tracksToReturn: [
          const Track(
            id: 'mock_local_1',
            title: 'Mock Local Song',
            artist: 'Local Artist',
            duration: Duration(minutes: 2, seconds: 45),
            audioUrl: 'content://media/external/audio/media/101',
          ),
        ],
      );

      repo = AudioPlayerRepositoryImpl(localAudioDataSource: mockDataSource);

      cubit = AudioPlayerCubit(
        audioPlayerRepository: repo,
        playTrackUseCase: PlayTrackUseCase(repo),
        pauseTrackUseCase: PauseTrackUseCase(repo),
        resumeTrackUseCase: ResumeTrackUseCase(repo),
        seekTrackUseCase: SeekTrackUseCase(repo),
        nextTrackUseCase: NextTrackUseCase(repo),
        previousTrackUseCase: PreviousTrackUseCase(repo),
        getPlaylistsUseCase: GetPlaylistsUseCase(repo),
        getTracksUseCase: GetTracksUseCase(repo),
        toggleFavoriteUseCase: ToggleFavoriteUseCase(repo),
        toggleSelectUseCase: ToggleSelectUseCase(repo),
        checkAudioPermissionsUseCase: CheckAudioPermissionsUseCase(repo),
        requestAudioPermissionsUseCase: RequestAudioPermissionsUseCase(repo),
        scanLocalTracksUseCase: ScanLocalTracksUseCase(repo),
      );
    });

    tearDown(() async {
      await cubit.close();
      if (repo is AudioPlayerRepositoryImpl) {
        (repo as AudioPlayerRepositoryImpl).dispose();
      }
    });

    test(
      'Initial load with permission denied sets AudioPermissionStatus.denied',
      () async {
        await cubit.loadInitialData();
        expect(cubit.state.permissionStatus, AudioPermissionStatus.denied);
      },
    );

    test('requestPermissionsAndScan grants permission and loads scanned local tracks', () async {
      mockDataSource.hasPermission = true;

      await cubit.requestPermissionsAndScan();
      expect(cubit.state.permissionStatus, AudioPermissionStatus.granted);
      expect(cubit.state.tracks, isNotEmpty);
      expect(cubit.state.tracks.first.id, 'mock_local_1');
      expect(cubit.state.hasScannedDevice, isTrue);
    });

    test('requestPermissionsAndScan sets error message when user denies permission', () async {
      mockDataSource.hasPermission = false;

      await cubit.requestPermissionsAndScan();
      expect(cubit.state.permissionStatus, AudioPermissionStatus.denied);
      expect(cubit.state.errorMessage, isNotNull);

      cubit.dismissError();
      expect(cubit.state.errorMessage, isNull);
    });

    test('refreshLibrary rescans tracks successfully', () async {
      mockDataSource.hasPermission = true;
      await cubit.requestPermissionsAndScan();

      // Add second track to mock data source
      mockDataSource.tracksToReturn = [
        const Track(
          id: 'mock_local_1',
          title: 'Mock Local Song',
          artist: 'Local Artist',
          duration: Duration(minutes: 2, seconds: 45),
          audioUrl: 'content://media/external/audio/media/101',
        ),
        const Track(
          id: 'mock_local_2',
          title: 'Second Scanned Song',
          artist: 'Another Artist',
          duration: Duration(minutes: 4, seconds: 10),
          audioUrl: 'content://media/external/audio/media/102',
        ),
      ];

      await cubit.refreshLibrary();
      expect(cubit.state.tracks.length, 2);
      expect(cubit.state.tracks.last.title, 'Second Scanned Song');
    });
  });
}
