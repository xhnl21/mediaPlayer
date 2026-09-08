import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/core/security/aes_encryption_service.dart';
import 'package:media_player/core/security/audit_logger.dart';
import 'package:media_player/core/security/input_sanitizer.dart';
import 'package:media_player/core/security/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  group('AES-256 Encryption & Security Subsystem Tests', () {
    late AesEncryptionService aesService;
    late SecureStorageService secureStorage;
    late AuditLogger auditLogger;

    setUp(() {
      aesService = AesEncryptionService(masterKeySeed: 'TEST_SEED_SECRET_KEY');
      secureStorage = SecureStorageService();
      auditLogger = AuditLogger(
        secureStorage: secureStorage,
        aesService: aesService,
      );
    });

    test('AES-256 encrypts and decrypts payload correctly', () {
      const original = 'Confidential_Bank_Grade_Audio_Metadata_12345';
      final encrypted = aesService.encrypt(original);

      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(original));

      final decrypted = aesService.decrypt(encrypted);
      expect(decrypted, equals(original));
    });

    test('AES-256 generates different ciphertexts for same plaintext due to random IV', () {
      const plaintext = 'Same_Sensitive_Message';
      final enc1 = aesService.encrypt(plaintext);
      final enc2 = aesService.encrypt(plaintext);

      expect(enc1, isNot(equals(enc2)));
      expect(aesService.decrypt(enc1), equals(plaintext));
      expect(aesService.decrypt(enc2), equals(plaintext));
    });

    test('InputSanitizer removes script tags and control characters', () {
      const dangerousInput = '<script>alert("hack")</script>Hello\x00World!';
      final sanitized = InputSanitizer.sanitizeText(dangerousInput);

      expect(sanitized.contains('<script>'), isFalse);
      expect(sanitized.contains('alert("hack")'), isTrue);
      expect(sanitized.contains('\x00'), isFalse);
    });

    test(
      'AuditLogger encrypts and logs security event to secure storage',
      () async {
        await auditLogger.logEvent(
          action: 'TEST_LOGIN_ATTEMPT',
          details: 'User attempt with id usr_01',
          severity: SecuritySeverity.medium,
        );

        final events = await auditLogger.getAuditEvents();
        expect(events, isNotEmpty);
        expect(events.first.action, 'TEST_LOGIN_ATTEMPT');
        expect(events.first.severity, SecuritySeverity.medium);
      },
    );
  });
}
