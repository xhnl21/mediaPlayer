import 'package:get_it/get_it.dart';
import 'package:media_player/application/application.dart';
import 'package:media_player/core/security/aes_encryption_service.dart';
import 'package:media_player/core/security/audit_logger.dart';
import 'package:media_player/core/security/secure_storage_service.dart';
import 'package:media_player/domain/domain.dart';
import 'package:media_player/infrastructure/infrastructure.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // 1. Core Security & Infrastructure
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

  // 2. Repositories
  sl.registerLazySingleton<SecurityAuditRepository>(
    () => SecurityAuditRepositoryImpl(auditLogger: sl<AuditLogger>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(secureDataSource: sl<SecureEncryptedDataSource>()),
  );
  sl.registerLazySingleton<AudioPlayerRepository>(
    () => AudioPlayerRepositoryImpl(),
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
