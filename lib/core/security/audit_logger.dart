import 'dart:convert';

import 'package:media_player/core/security/aes_encryption_service.dart';
import 'package:media_player/core/security/secure_storage_service.dart';

enum SecuritySeverity { low, medium, high, critical }

class SecurityAuditEvent {
  SecurityAuditEvent({
    required this.action,
    required this.details,
    required this.severity,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().toUtc();

  factory SecurityAuditEvent.fromJson(Map<String, dynamic> json) {
    return SecurityAuditEvent(
      action: json['action'] as String,
      details: json['details'] as String,
      severity: SecuritySeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => SecuritySeverity.low,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  final String action;
  final String details;
  final SecuritySeverity severity;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
    'action': action,
    'details': details,
    'severity': severity.name,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// OWASP MASVS Security Audit Logger.
/// Encrypts every audit entry with AES-256 before persisting into Secure Storage.
class AuditLogger {
  AuditLogger({required this.secureStorage, required this.aesService});

  final SecureStorageService secureStorage;
  final AesEncryptionService aesService;
  static const String _auditStorageKey = 'SECURE_AUDIT_LOG_STREAM';

  Future<void> logEvent({
    required String action,
    required String details,
    SecuritySeverity severity = SecuritySeverity.low,
  }) async {
    final event = SecurityAuditEvent(
      action: action,
      details: details,
      severity: severity,
    );

    final eventJson = jsonEncode(event.toJson());
    final encrypted = aesService.encrypt(eventJson);

    final existing = await secureStorage.read(key: _auditStorageKey) ?? '';
    final updated = existing.isEmpty ? encrypted : '$existing\n$encrypted';
    await secureStorage.write(key: _auditStorageKey, value: updated);
  }

  Future<List<SecurityAuditEvent>> getAuditEvents() async {
    final raw = await secureStorage.read(key: _auditStorageKey);
    if (raw == null || raw.trim().isEmpty) return [];

    final lines = raw.split('\n');
    final events = <SecurityAuditEvent>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        final decrypted = aesService.decrypt(line.trim());
        final map = jsonDecode(decrypted) as Map<String, dynamic>;
        events.add(SecurityAuditEvent.fromJson(map));
      } catch (_) {
        // Continue parsing remaining valid log entries
      }
    }
    return events;
  }
}
