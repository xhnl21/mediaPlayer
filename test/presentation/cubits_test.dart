import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/application/application.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/infrastructure/infrastructure.dart';
import 'package:media_player/presentation/cubits.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  group('Presentation Cubits Tests', () {
    test(
      'NavigationCubit changes screens and updates bottomNavIndex correctly',
      () {
        final navCubit = NavigationCubit();
        expect(navCubit.state.currentScreen, AppScreen.welcome);

        navCubit.navigateTo(AppScreen.dashboardGrid);
        expect(navCubit.state.currentScreen, AppScreen.dashboardGrid);
        expect(navCubit.state.bottomNavIndex, 0);

        navCubit.changeBottomNavIndex(3);
        expect(navCubit.state.currentScreen, AppScreen.equalizer);
        expect(navCubit.state.bottomNavIndex, 3);
      },
    );

    test(
      'AudioPlayerCubit loads tracks, toggles playback and selects tracks',
      () async {
        final repo = AudioPlayerRepositoryImpl();
        final cubit = AudioPlayerCubit(
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
        );

        await cubit.loadInitialData();
        expect(cubit.state.tracks, isNotEmpty);

        final firstTrack = cubit.state.tracks.first;
        await cubit.playTrack(firstTrack);
        expect(cubit.state.currentTrack?.id, firstTrack.id);
        expect(cubit.state.isPlaying, isTrue);

        await cubit.togglePlayPause();
        expect(cubit.state.isPlaying, isFalse);

        await cubit.close();
        repo.dispose();
      },
    );

    test(
      'EqualizerCubit updates band gains, presets and rotary knobs',
      () async {
        final aes = AesEncryptionService(masterKeySeed: 'TEST_EQ_SEED');
        final secure = SecureStorageService();
        final secData = SecureEncryptedDataSource(
          secureStorage: secure,
          aesService: aes,
        );
        final repo = EqualizerRepositoryImpl(secureDataSource: secData);

        final cubit = EqualizerCubit(
          getEqualizerSettingUseCase: GetEqualizerSettingUseCase(repo),
          updateEqualizerBandUseCase: UpdateEqualizerBandUseCase(repo),
          updateEqualizerDialsUseCase: UpdateEqualizerDialsUseCase(repo),
          selectEqualizerPresetUseCase: SelectEqualizerPresetUseCase(repo),
          saveEqualizerSettingsUseCase: SaveEqualizerSettingsUseCase(repo),
        );

        await cubit.loadSettings();
        expect(cubit.state.setting.bands.length, 6);

        await cubit.setBass(0.9);
        expect(cubit.state.setting.bass, 0.9);

        await cubit.selectPreset('Ipsum');
        expect(cubit.state.setting.selectedPreset, 'Ipsum');

        await cubit.save();
        expect(cubit.state.isSaved, isTrue);
      },
    );

    test('SettingsCubit toggles sound options and persists state', () async {
      final aes = AesEncryptionService(masterKeySeed: 'TEST_SETTINGS_SEED');
      final secure = SecureStorageService();
      final secData = SecureEncryptedDataSource(
        secureStorage: secure,
        aesService: aes,
      );
      final repo = SettingsRepositoryImpl(secureDataSource: secData);
      final auditLogger = AuditLogger(secureStorage: secure, aesService: aes);
      final auditRepo = SecurityAuditRepositoryImpl(auditLogger: auditLogger);

      final cubit = SettingsCubit(
        getSettingsUseCase: GetSettingsUseCase(repo),
        updateSettingsUseCase: UpdateSettingsUseCase(
          settingsRepository: repo,
          auditRepository: auditRepo,
        ),
      );

      await cubit.loadSettings();
      cubit.toggleDolorSitAmet(true);
      expect(cubit.state.settings.dolorSitAmet, isTrue);

      await cubit.saveSettings();
      expect(cubit.state.isSaved, isTrue);
    });
  });
}
