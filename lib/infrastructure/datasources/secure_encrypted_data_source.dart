import 'dart:convert';

import 'package:media_player/core/security/aes_encryption_service.dart';
import 'package:media_player/core/security/secure_storage_service.dart';

class SecureEncryptedDataSource {
  SecureEncryptedDataSource({
    required this.secureStorage,
    required this.aesService,
  });

  final SecureStorageService secureStorage;
  final AesEncryptionService aesService;

  Future<void> saveEncryptedJson({
    required String key,
    required Map<String, dynamic> data,
  }) async {
    final rawJson = jsonEncode(data);
    final encrypted = aesService.encrypt(rawJson);
    await secureStorage.write(key: key, value: encrypted);
  }

  Future<Map<String, dynamic>?> getEncryptedJson({required String key}) async {
    final encrypted = await secureStorage.read(key: key);
    if (encrypted == null || encrypted.isEmpty) return null;
    try {
      final decrypted = aesService.decrypt(encrypted);
      return jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> remove({required String key}) async {
    await secureStorage.delete(key: key);
  }
}
