import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:media_player/core/errors/exceptions.dart';
import 'package:media_player/domain/entities/user_profile.dart';
import 'package:media_player/domain/repositories/auth_repository.dart';
import 'package:media_player/domain/value_objects/email_address.dart';
import 'package:media_player/domain/value_objects/password.dart';
import 'package:media_player/infrastructure/datasources/secure_encrypted_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.secureDataSource});

  final SecureEncryptedDataSource secureDataSource;
  static const String _userSessionKey = 'AUTH_ACTIVE_USER_SESSION';
  static const String _userCredentialsKey = 'AUTH_STORED_CREDENTIALS';

  String _hashPassword(String password, String salt) {
    return sha256.convert(utf8.encode('$salt$password')).toString();
  }

  @override
  Future<UserProfile> login({
    required EmailAddress email,
    required Password password,
  }) async {
    final credentials = await secureDataSource.getEncryptedJson(
      key: _userCredentialsKey,
    );

    if (credentials != null) {
      final storedEmail = credentials['email'] as String;
      final storedHash = credentials['passwordHash'] as String;
      final salt = credentials['salt'] as String;

      final incomingHash = _hashPassword(password.value, salt);
      if (storedEmail == email.value && storedHash == incomingHash) {
        final profile = UserProfile(
          id: credentials['id'] as String,
          name: credentials['name'] as String,
          email: EmailAddress(credentials['email'] as String),
          phone: credentials['phone'] as String,
        );
        await _saveSession(profile);
        return profile;
      } else {
        throw SecurityException('Invalid credentials provided');
      }
    }

    // Default seeded demo user matching mockups
    const salt = 'DEMO_SALT_SECURE_2026';
    final user = UserProfile(
      id: 'usr_default_01',
      name: 'Lorem Name',
      email: email,
      phone: '+1 555 019 2834',
      statusMessage: 'Dolor sit amet \n Hicius 25489',
    );
    await secureDataSource.saveEncryptedJson(
      key: _userCredentialsKey,
      data: {
        'id': user.id,
        'name': user.name,
        'email': user.email.value,
        'phone': user.phone,
        'salt': salt,
        'passwordHash': _hashPassword(password.value, salt),
      },
    );
    await _saveSession(user);
    return user;
  }

  @override
  Future<UserProfile> register({
    required String name,
    required EmailAddress email,
    required String phone,
    required Password password,
  }) async {
    final salt = DateTime.now().millisecondsSinceEpoch.toString();
    final user = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      statusMessage: 'Dolor sit amet \n Hicius 25489',
    );

    await secureDataSource.saveEncryptedJson(
      key: _userCredentialsKey,
      data: {
        'id': user.id,
        'name': user.name,
        'email': user.email.value,
        'phone': user.phone,
        'salt': salt,
        'passwordHash': _hashPassword(password.value, salt),
      },
    );
    await _saveSession(user);
    return user;
  }

  Future<void> _saveSession(UserProfile user) async {
    await secureDataSource.saveEncryptedJson(
      key: _userSessionKey,
      data: {
        'id': user.id,
        'name': user.name,
        'email': user.email.value,
        'phone': user.phone,
        'statusMessage': user.statusMessage,
      },
    );
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    final json = await secureDataSource.getEncryptedJson(key: _userSessionKey);
    if (json == null) return null;
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: EmailAddress(json['email'] as String),
      phone: json['phone'] as String,
      statusMessage: json['statusMessage'] as String? ?? 'Dolor sit amet',
    );
  }

  @override
  Future<void> logout() async {
    await secureDataSource.remove(key: _userSessionKey);
  }
}
