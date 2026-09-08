import 'package:media_player/domain/entities/user_profile.dart';
import 'package:media_player/domain/repositories/auth_repository.dart';
import 'package:media_player/domain/repositories/security_audit_repository.dart';
import 'package:media_player/domain/value_objects/email_address.dart';
import 'package:media_player/domain/value_objects/password.dart';

class LoginUseCase {
  const LoginUseCase({
    required this.authRepository,
    required this.auditRepository,
  });

  final AuthRepository authRepository;
  final SecurityAuditRepository auditRepository;

  Future<UserProfile> execute({
    required EmailAddress email,
    required Password password,
  }) async {
    try {
      final user = await authRepository.login(email: email, password: password);
      await auditRepository.logSecurityEvent(
        action: 'AUTH_LOGIN_SUCCESS',
        details: 'User ${user.email} logged in successfully',
      );
      return user;
    } catch (e) {
      await auditRepository.logSecurityEvent(
        action: 'AUTH_LOGIN_FAILURE',
        details: 'Failed login attempt for ${email.value}: $e',
      );
      rethrow;
    }
  }
}

class RegisterUseCase {
  const RegisterUseCase({
    required this.authRepository,
    required this.auditRepository,
  });

  final AuthRepository authRepository;
  final SecurityAuditRepository auditRepository;

  Future<UserProfile> execute({
    required String name,
    required EmailAddress email,
    required String phone,
    required Password password,
  }) async {
    try {
      final user = await authRepository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      await auditRepository.logSecurityEvent(
        action: 'AUTH_REGISTER_SUCCESS',
        details: 'New user registered: ${user.email}',
      );
      return user;
    } catch (e) {
      await auditRepository.logSecurityEvent(
        action: 'AUTH_REGISTER_FAILURE',
        details: 'Failed registration for $name: $e',
      );
      rethrow;
    }
  }
}

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this.authRepository);
  final AuthRepository authRepository;

  Future<UserProfile?> execute() => authRepository.getCurrentUser();
}

class LogoutUseCase {
  const LogoutUseCase({
    required this.authRepository,
    required this.auditRepository,
  });

  final AuthRepository authRepository;
  final SecurityAuditRepository auditRepository;

  Future<void> execute() async {
    await auditRepository.logSecurityEvent(
      action: 'AUTH_LOGOUT',
      details: 'User logged out',
    );
    await authRepository.logout();
  }
}
