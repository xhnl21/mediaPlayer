import 'package:media_player/core/security/audit_logger.dart';

abstract class SecurityAuditRepository {
  Future<void> logSecurityEvent({
    required String action,
    required String details,
    SecuritySeverity severity = SecuritySeverity.low,
  });

  Future<List<SecurityAuditEvent>> getAuditHistory();
}
