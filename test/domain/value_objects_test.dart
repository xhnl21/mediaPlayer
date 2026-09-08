import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/domain/value_objects/audio_frequency.dart';
import 'package:media_player/domain/value_objects/email_address.dart';
import 'package:media_player/domain/value_objects/equalizer_gain.dart';
import 'package:media_player/domain/value_objects/password.dart';

void main() {
  group('Domain Value Objects Tests', () {
    test('EmailAddress valid format creates successfully', () {
      final email = EmailAddress('user@example.com');
      expect(email.value, 'user@example.com');
      expect(EmailAddress.isValid('user@example.com'), isTrue);
    });

    test('EmailAddress invalid format throws ArgumentError', () {
      expect(() => EmailAddress('invalid-email'), throwsArgumentError);
      expect(EmailAddress.isValid('invalid-email'), isFalse);
    });

    test('Password valid policy creates successfully', () {
      final pass = Password('Secret123');
      expect(pass.value, 'Secret123');
      expect(Password.isValid('Secret123'), isTrue);
    });

    test('Password invalid policy throws ArgumentError', () {
      expect(() => Password('123'), throwsArgumentError);
      expect(() => Password('onlyletters'), throwsArgumentError);
    });

    test('AudioFrequency formats and validates properly', () {
      const freq = AudioFrequency(102.5);
      expect(freq.mhz, 102.5);
      expect(freq.formatted, '102.5 MHz');
    });

    test('EqualizerGain normalizes and clamps between -12dB and +12dB', () {
      const gainZero = EqualizerGain(0.0);
      expect(gainZero.normalized, closeTo(0.5, 0.01));

      final gainFromNorm = EqualizerGain.fromNormalized(1.0);
      expect(gainFromNorm.value, 12.0);

      const gainClamped = EqualizerGain(25.0);
      expect(gainClamped.value, 12.0);
    });
  });
}
