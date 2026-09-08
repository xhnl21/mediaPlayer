import 'package:equatable/equatable.dart';

/// Base Failure class for Domain errors.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class SecurityFailure extends Failure {
  const SecurityFailure([super.message = 'Security violation detected']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation rule failed']);
}

class AudioPlaybackFailure extends Failure {
  const AudioPlaybackFailure([super.message = 'Audio playback error']);
}
