import 'package:equatable/equatable.dart';
import 'package:media_player/core/security/input_sanitizer.dart';

/// Strongly-typed Value Object for Email Address.
class EmailAddress extends Equatable {
  const EmailAddress._(this.value);

  final String value;

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  /// Validates and constructs an EmailAddress.
  /// Throws [ArgumentError] if invalid.
  factory EmailAddress(String input) {
    final sanitized = InputSanitizer.sanitizeText(input);
    if (!_emailRegExp.hasMatch(sanitized)) {
      throw ArgumentError('Invalid email address format: $input');
    }
    return EmailAddress._(sanitized);
  }

  /// Safe validator without throwing.
  static bool isValid(String input) {
    final sanitized = InputSanitizer.sanitizeText(input);
    return _emailRegExp.hasMatch(sanitized);
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
