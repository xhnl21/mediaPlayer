import 'package:media_player/core/security/audit_logger.dart';
import 'package:media_player/domain/repositories/security_audit_repository.dart';

class SecurityAuditRepositoryImpl implements SecurityAuditRepository {
  SecurityAuditRepositoryImpl({required this.auditLogger});

  final AuditLogger auditLogger;

  @override
  Future<void> logSecurityEvent({
    required String action,
    required String details,
    SecuritySeverity severity = SecuritySeverity.low,
  }) async {
    await auditLogger.logEvent(
      action: action,
      details: details,
      severity: severity,
    );
  }

  @override
  Future<List<SecurityAuditEvent>> getAuditHistory() async {
    return auditLogger.getAuditEvents();
  }
}
