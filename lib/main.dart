import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/application/application.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/domain/domain.dart';
import 'package:media_player/presentation/presentation.dart';

class _AppLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Force pipeline refresh on return from lockscreen/background
      WidgetsBinding.instance.scheduleFrame();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lifecycle observer to prevent UI lock/black screens on resume
  WidgetsBinding.instance.addObserver(_AppLifecycleObserver());

  // Global safe error handling to prevent black screen on uncaught build errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError caught: ${details.exceptionAsString()}');
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.accentCoral,
                  size: 56,
                ),
                const SizedBox(height: 16),
                const Texts(
                  'Algo salió mal en la interfaz',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 8),
                const Texts(
                  'La aplicación se ha recuperado para evitar cierres inesperados.',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentCoral,
                    foregroundColor: AppColors.textLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('REINTENTAR'),
                  onPressed: () {
                    WidgetsBinding.instance.scheduleFrame();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  await initDependencies();
  runApp(const MediaPlayerApp());
}

class MediaPlayerApp extends StatelessWidget {
  const MediaPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(
            loginUseCase: sl<LoginUseCase>(),
            registerUseCase: sl<RegisterUseCase>(),
            getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
            logoutUseCase: sl<LogoutUseCase>(),
          )..checkAuthStatus(),
        ),
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
            preferencesRepository: sl<PlayerPreferencesRepository>(),
            checkAudioPermissionsUseCase: sl<CheckAudioPermissionsUseCase>(),
            requestAudioPermissionsUseCase:
                sl<RequestAudioPermissionsUseCase>(),
            scanLocalTracksUseCase: sl<ScanLocalTracksUseCase>(),
          ),
        ),
        BlocProvider<FavoritesCubit>(
          create: (_) => FavoritesCubit(
            getFavoritesUseCase: sl<GetFavoritesUseCase>(),
            toggleFavoriteTrackUseCase: sl<ToggleFavoriteTrackUseCase>(),
            removeFavoriteTrackUseCase: sl<RemoveFavoriteTrackUseCase>(),
            favoritesRepository: sl<FavoritesRepository>(),
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
      child: Builder(
        builder: (context) {
          final router = AppRouter.createRouter(context.read<AuthCubit>());
          return MaterialApp.router(
            title: 'Media Player',
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: AppColors.background,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primaryTeal,
                primary: AppColors.primaryTeal,
                secondary: AppColors.accentCoral,
                surface: AppColors.cardSurface,
              ),
            ),
          );
        },
      ),
    );
  }
}
