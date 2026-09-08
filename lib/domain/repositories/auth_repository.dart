import 'package:media_player/domain/entities/user_profile.dart';
import 'package:media_player/domain/value_objects/email_address.dart';
import 'package:media_player/domain/value_objects/password.dart';

abstract class AuthRepository {
  Future<UserProfile> login({
    required EmailAddress email,
    required Password password,
  });

  Future<UserProfile> register({
    required String name,
    required EmailAddress email,
    required String phone,
    required Password password,
  });

  Future<UserProfile?> getCurrentUser();

  Future<void> logout();
}
