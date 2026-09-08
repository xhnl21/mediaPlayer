import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/application/application.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/domain/domain.dart';
import 'package:media_player/presentation/presentation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  setUpAll(() async {
    await initDependencies();
  });

  Widget buildTestApp({
    required AuthCubit authCubit,
    String initialLocation = RouteNames.welcome,
  }) {
    final router = AppRouter.createRouter(
      authCubit,
      initialLocation: initialLocation,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
        BlocProvider<AudioPlayerCubit>(
          create: (_) => AudioPlayerCubit(
            audioPlayerRepository: sl<AudioPlayerRepository>(),
            playTrackUseCase: sl<PlayTrackUseCase>(),
            pauseTrackUseCase: sl<PauseTrackUseCase>(),
            resumeTrackUseCase: sl<ResumeTrackUseCase>(),
            seekTrackUseCase: sl<SeekTrackUseCase>(),
            nextTrackUseCase: sl<NextTrackUseCase>(),
            previousTrackUseCase: sl<PreviousTrackUseCase>(),
            getPlaylistsUseCase: sl<GetPlaylistsUseCase>(),
            getTracksUseCase: sl<GetTracksUseCase>(),
            toggleFavoriteUseCase: sl<ToggleFavoriteUseCase>(),
            toggleSelectUseCase: sl<ToggleSelectUseCase>(),
            checkAudioPermissionsUseCase: sl<CheckAudioPermissionsUseCase>(),
            requestAudioPermissionsUseCase:
                sl<RequestAudioPermissionsUseCase>(),
            scanLocalTracksUseCase: sl<ScanLocalTracksUseCase>(),
          ),
        ),
        BlocProvider<LibraryCubit>(
          create: (_) => LibraryCubit(
            getPlaylistsUseCase: sl<GetPlaylistsUseCase>(),
            getTracksUseCase: sl<GetTracksUseCase>(),
            searchTracksUseCase: sl<SearchTracksUseCase>(),
          ),
        ),
        BlocProvider<EqualizerCubit>(
          create: (_) => EqualizerCubit(
            getEqualizerSettingUseCase: sl<GetEqualizerSettingUseCase>(),
            updateEqualizerBandUseCase: sl<UpdateEqualizerBandUseCase>(),
            updateEqualizerDialsUseCase: sl<UpdateEqualizerDialsUseCase>(),
            selectEqualizerPresetUseCase: sl<SelectEqualizerPresetUseCase>(),
            saveEqualizerSettingsUseCase: sl<SaveEqualizerSettingsUseCase>(),
          ),
        ),
        BlocProvider<RadioCubit>(
          create: (_) => RadioCubit(
            radioRepository: sl<RadioRepository>(),
            getRadioStationsUseCase: sl<GetRadioStationsUseCase>(),
            tuneRadioFrequencyUseCase: sl<TuneRadioFrequencyUseCase>(),
            toggleRadioPlaybackUseCase: sl<ToggleRadioPlaybackUseCase>(),
            nextRadioStationUseCase: sl<NextRadioStationUseCase>(),
            previousRadioStationUseCase: sl<PreviousRadioStationUseCase>(),
            setRadioVolumeUseCase: sl<SetRadioVolumeUseCase>(),
          ),
        ),
        BlocProvider<RecorderCubit>(
          create: (_) => RecorderCubit(
            recorderRepository: sl<VoiceRecorderRepository>(),
            startVoiceRecordingUseCase: sl<StartVoiceRecordingUseCase>(),
            stopVoiceRecordingUseCase: sl<StopVoiceRecordingUseCase>(),
            getVoiceRecordingsUseCase: sl<GetVoiceRecordingsUseCase>(),
            deleteVoiceRecordingUseCase: sl<DeleteVoiceRecordingUseCase>(),
          ),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(
            getSettingsUseCase: sl<GetSettingsUseCase>(),
            updateSettingsUseCase: sl<UpdateSettingsUseCase>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }

  group('AppRouter Declarative Navigation Tests', () {
    late AuthCubit authCubit;

    setUp(() {
      authCubit = AuthCubit(
        loginUseCase: sl<LoginUseCase>(),
        registerUseCase: sl<RegisterUseCase>(),
        getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
        logoutUseCase: sl<LogoutUseCase>(),
      );
    });

    tearDown(() {
      authCubit.close();
    });

    testWidgets(
      'Unauthenticated user is redirected from protected route to /welcome',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            authCubit: authCubit,
            initialLocation: RouteNames.dashboard,
          ),
        );
        await tester.pumpAndSettle();

        // Guard should redirect to WelcomeScreen
        expect(find.byType(WelcomeScreen), findsOneWidget);
        expect(find.text('MOBILE APP'), findsOneWidget);
      },
    );

    testWidgets(
      'Authenticated user is redirected from /welcome to /dashboard',
      (tester) async {
        // Authenticate first
        await authCubit.continueAsGuest();

        await tester.pumpWidget(
          buildTestApp(
            authCubit: authCubit,
            initialLocation: RouteNames.welcome,
          ),
        );
        await tester.pumpAndSettle();

        // Guard should redirect to DashboardGridScreen inside MainShellScreen
        expect(find.byType(MainShellScreen), findsOneWidget);
        expect(find.byType(DashboardGridScreen), findsOneWidget);
      },
    );

    testWidgets('Displays 404 Not Found screen on unknown path', (
      tester,
    ) async {
      await authCubit.continueAsGuest();

      await tester.pumpWidget(
        buildTestApp(
          authCubit: authCubit,
          initialLocation: '/non-existent-random-route',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('404 - Page Not Found'), findsOneWidget);
      expect(find.text('GO HOME'), findsOneWidget);

      // Tapping GO HOME navigates back to valid route
      await tester.tap(find.text('GO HOME'));
      await tester.pumpAndSettle();

      // Authenticated user redirected to dashboard
      expect(find.byType(DashboardGridScreen), findsOneWidget);
    });

    testWidgets(
      'ShellRoute renders nested screens and bottom nav for protected routes',
      (tester) async {
        await authCubit.continueAsGuest();

        await tester.pumpWidget(
          buildTestApp(
            authCubit: authCubit,
            initialLocation: RouteNames.search,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MainShellScreen), findsOneWidget);
        expect(find.byType(SearchGenresScreen), findsOneWidget);
        expect(find.byType(CustomBottomNavBar), findsOneWidget);
      },
    );

    testWidgets('Deep link navigation to /equalizer resolves correctly', (
      tester,
    ) async {
      await authCubit.continueAsGuest();

      await tester.pumpWidget(
        buildTestApp(
          authCubit: authCubit,
          initialLocation: RouteNames.equalizer,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MainShellScreen), findsOneWidget);
      expect(find.byType(EqualizerScreen), findsOneWidget);
    });
  });
}
