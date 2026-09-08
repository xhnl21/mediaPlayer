import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/application/application.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/domain/domain.dart';
import 'package:media_player/presentation/presentation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      child: MaterialApp(
        title: 'Media Player',
        debugShowCheckedModeBanner: false,
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
        home: const MainShellScreen(),
      ),
    );
  }
}
