import 'package:media_player/domain/entities/audio_settings.dart';
import 'package:media_player/domain/repositories/security_audit_repository.dart';
import 'package:media_player/domain/repositories/settings_repository.dart';

class GetSettingsUseCase {
  const GetSettingsUseCase(this.repository);
  final SettingsRepository repository;

  Future<AudioSettings> execute() => repository.getSettings();
}

class UpdateSettingsUseCase {
  const UpdateSettingsUseCase({
    required this.settingsRepository,
    required this.auditRepository,
  });

  final SettingsRepository settingsRepository;
  final SecurityAuditRepository auditRepository;

  Future<void> execute(AudioSettings settings) async {
    await settingsRepository.updateSettings(settings);
    await settingsRepository.saveSettings();
    await auditRepository.logSecurityEvent(
      action: 'SETTINGS_UPDATED',
      details: 'Audio configuration toggles changed and encrypted',
    );
  }
}
