import 'package:equatable/equatable.dart';

/// Strongly-typed Value Object for User Password.
/// Enforces OWASP MASVS password policy: at least 6 characters, contains letters and numbers.
class Password extends Equatable {
  const Password._(this.value);

  final String value;

  factory Password(String input) {
    if (!isValid(input)) {
      throw ArgumentError(
        'Password must be at least 6 characters and contain both letters and digits.',
      );
    }
    return Password._(input);
  }

  static bool isValid(String input) {
    if (input.length < 6) return false;
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(input);
    final hasDigit = RegExp(r'[0-9]').hasMatch(input);
    return hasLetter && hasDigit;
  }

  @override
  List<Object?> get props => [value];
}
