import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:media_player/application/application.dart';
import 'package:media_player/core/security/aes_encryption_service.dart';
import 'package:media_player/core/security/audit_logger.dart';
import 'package:media_player/core/security/secure_storage_service.dart';
import 'package:media_player/domain/domain.dart';
import 'package:media_player/infrastructure/infrastructure.dart';

final sl = GetIt.instance;

Future<void> initDependencies({
  AudioPlayerHandlerImpl? audioHandler,
  bool enableBackgroundService = true,
}) async {
  // 1. Audio Service & Background Playback Handler
  AudioPlayerHandlerImpl? handler = audioHandler;
  final isTest = Platform.environment.containsKey('FLUTTER_TEST');

  if (handler == null && enableBackgroundService && !isTest) {
    try {
      handler = await AudioService.init<AudioPlayerHandlerImpl>(
        builder: () => AudioPlayerHandlerImpl(),
        config: const AudioServiceConfig(
          androidNotificationChannelId:
              'com.antigravity.mediaplayer.channel.audio',
          androidNotificationChannelName: 'Media Player Audio Playback',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          androidNotificationIcon: 'mipmap/ic_launcher',
          androidShowNotificationBadge: true,
        ),
      );
    } catch (e) {
      debugPrint('AudioService.init skipped or unavailable: $e');
    }
  }

  if (handler != null && !sl.isRegistered<AudioPlayerHandlerImpl>()) {
    sl.registerSingleton<AudioPlayerHandlerImpl>(handler);
  }

  // 2. Core Security & Infrastructure
  sl.registerLazySingleton<AesEncryptionService>(() => AesEncryptionService());
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<AuditLogger>(
    () => AuditLogger(
      secureStorage: sl<SecureStorageService>(),
      aesService: sl<AesEncryptionService>(),
    ),
  );
  sl.registerLazySingleton<SecureEncryptedDataSource>(
    () => SecureEncryptedDataSource(
      secureStorage: sl<SecureStorageService>(),
      aesService: sl<AesEncryptionService>(),
    ),
  );

  sl.registerLazySingleton<LocalAudioDataSource>(
    () => LocalAudioDataSourceImpl(),
  );
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
  sl.registerLazySingleton<DriftFavoritesDataSource>(
    () => DriftFavoritesDataSourceImpl(sl<AppDatabase>()),
  );

  // 3. Repositories
  sl.registerLazySingleton<SecurityAuditRepository>(
    () => SecurityAuditRepositoryImpl(auditLogger: sl<AuditLogger>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(secureDataSource: sl<SecureEncryptedDataSource>()),
  );
  sl.registerLazySingleton<AudioPlayerRepository>(
    () => AudioPlayerRepositoryImpl(
      audioHandler: sl.isRegistered<AudioPlayerHandlerImpl>()
          ? sl<AudioPlayerHandlerImpl>()
          : null,
      localAudioDataSource: sl<LocalAudioDataSource>(),
    ),
  );
  sl.registerLazySingleton<EqualizerRepository>(
    () => EqualizerRepositoryImpl(
      secureDataSource: sl<SecureEncryptedDataSource>(),
    ),
  );
  sl.registerLazySingleton<RadioRepository>(() => RadioRepositoryImpl());
  sl.registerLazySingleton<VoiceRecorderRepository>(
    () => VoiceRecorderRepositoryImpl(),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      secureDataSource: sl<SecureEncryptedDataSource>(),
    ),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(dataSource: sl<DriftFavoritesDataSource>()),
  );

  // 3. Application Use Cases
  // Auth
  sl.registerLazySingleton(
    () => LoginUseCase(
      authRepository: sl<AuthRepository>(),
      auditRepository: sl<SecurityAuditRepository>(),
    ),
  );
  sl.registerLazySingleton(
    () => RegisterUseCase(
      authRepository: sl<AuthRepository>(),
      auditRepository: sl<SecurityAuditRepository>(),
    ),
  );
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(
    () => LogoutUseCase(
      authRepository: sl<AuthRepository>(),
      auditRepository: sl<SecurityAuditRepository>(),
    ),
  );

  // Player
  sl.registerLazySingleton(() => PlayTrackUseCase(sl<AudioPlayerRepository>()));
  sl.registerLazySingleton(
    () => PauseTrackUseCase(sl<AudioPlayerRepository>()),
  );
  sl.registerLazySingleton(
    () => ResumeTrackUseCase(sl<AudioPlayerRepository>()),
  );
  sl.registerLazySingleton(() => SeekTrackUseCase(sl<AudioPlayerRepository>()));
  sl.registerLazySingleton(() => NextTrackUseCase(sl<AudioPlayerRepository>()));
  sl.registerLazySingleton(
    () => PreviousTrackUseCase(sl<AudioPlayerRepository>()),
  );
  sl.registerLazySingleton(
    () => GetPlaylistsUseCase(sl<AudioPlayerRepository>()),
  );
  sl.registerLazySingleton(() => GetTracksUseCase(sl<AudioPlayerRepository>()));
  sl.registerLazySingleton(
    () => SearchTracksUseCase(sl<AudioPlayerRepository>()),
  );
  sl.registerLazySingleton(
    () => ToggleFavoriteUseCase(sl<AudioPlayerRepository>()),
  );
  sl.registerLazySingleton(
    () => ToggleSelectUseCase(sl<AudioPlayerRepository>()),
  );
  sl.registerLazySingleton(
    () => CheckAudioPermissionsUseCase(sl<AudioPlayerRepository>()),
  );
  sl.registerLazySingleton(
    () => RequestAudioPermissionsUseCase(sl<AudioPlayerRepository>()),
  );
  sl.registerLazySingleton(
    () => ScanLocalTracksUseCase(sl<AudioPlayerRepository>()),
  );
  sl.registerLazySingleton(
    () => RemoveTrackUseCase(sl<AudioPlayerRepository>()),
  );
  sl.registerLazySingleton(
    () => RemoveTracksUseCase(sl<AudioPlayerRepository>()),
  );
  sl.registerLazySingleton(
    () => SetRepeatModeUseCase(sl<AudioPlayerRepository>()),
  );
  sl.registerLazySingleton(
    () => SetShuffleModeUseCase(sl<AudioPlayerRepository>()),
  );

  // Favorites
  sl.registerLazySingleton(
    () => GetFavoritesUseCase(sl<FavoritesRepository>()),
  );
  sl.registerLazySingleton(
    () => ToggleFavoriteTrackUseCase(sl<FavoritesRepository>()),
  );
  sl.registerLazySingleton(() => IsFavoriteUseCase(sl<FavoritesRepository>()));
  sl.registerLazySingleton(
    () => RemoveFavoriteTrackUseCase(sl<FavoritesRepository>()),
  );

  // Equalizer
  sl.registerLazySingleton(
    () => GetEqualizerSettingUseCase(sl<EqualizerRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateEqualizerBandUseCase(sl<EqualizerRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateEqualizerDialsUseCase(sl<EqualizerRepository>()),
  );
  sl.registerLazySingleton(
    () => SelectEqualizerPresetUseCase(sl<EqualizerRepository>()),
  );
  sl.registerLazySingleton(
    () => SaveEqualizerSettingsUseCase(sl<EqualizerRepository>()),
  );

  // Radio
  sl.registerLazySingleton(
    () => GetRadioStationsUseCase(sl<RadioRepository>()),
  );
  sl.registerLazySingleton(
    () => TuneRadioFrequencyUseCase(sl<RadioRepository>()),
  );
  sl.registerLazySingleton(
    () => ToggleRadioPlaybackUseCase(sl<RadioRepository>()),
  );
  sl.registerLazySingleton(
    () => NextRadioStationUseCase(sl<RadioRepository>()),
  );
  sl.registerLazySingleton(
    () => PreviousRadioStationUseCase(sl<RadioRepository>()),
  );
  sl.registerLazySingleton(() => SetRadioVolumeUseCase(sl<RadioRepository>()));

  // Voice Recorder
  sl.registerLazySingleton(
    () => StartVoiceRecordingUseCase(sl<VoiceRecorderRepository>()),
  );
  sl.registerLazySingleton(
    () => StopVoiceRecordingUseCase(sl<VoiceRecorderRepository>()),
  );
  sl.registerLazySingleton(
    () => GetVoiceRecordingsUseCase(sl<VoiceRecorderRepository>()),
  );
  sl.registerLazySingleton(
    () => DeleteVoiceRecordingUseCase(sl<VoiceRecorderRepository>()),
  );

  // Settings
  sl.registerLazySingleton(() => GetSettingsUseCase(sl<SettingsRepository>()));
  sl.registerLazySingleton(
    () => UpdateSettingsUseCase(
      settingsRepository: sl<SettingsRepository>(),
      auditRepository: sl<SecurityAuditRepository>(),
    ),
  );
}
