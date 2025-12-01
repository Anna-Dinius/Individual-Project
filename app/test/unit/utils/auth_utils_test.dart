import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/utils/auth_utils.dart';

void main() {
  group('Auth utils', () {
    test('validateEmailFormat null or empty returns Required', () {
      expect(validateEmailFormat(null), 'Required');
      expect(validateEmailFormat('   '), 'Required');
    });

    test('validateEmailFormat invalid formats', () {
      expect(validateEmailFormat('no-at-symbol'), 'Enter a valid email');
      // missing a dot
      expect(validateEmailFormat('nodot@domain'), 'Enter a valid email');
    });

    test('validateEmailFormat valid', () {
      expect(validateEmailFormat('a@b.com'), isNull);
    });

    test('validatePasswordFormat checks required and length', () {
      expect(validatePasswordFormat(null), 'Required');
      expect(validatePasswordFormat('  '), 'Required');
      expect(
        validatePasswordFormat('short'),
        'Password must be at least 6 characters',
      );
      expect(validatePasswordFormat('longenough'), isNull);
    });

    test('validatePasswordsMatch handles equality and nulls', () {
      expect(validatePasswordsMatch('a', 'a'), isTrue);
      expect(validatePasswordsMatch('a', 'b'), isFalse);
      // Both null -> considered match by implementation
      expect(validatePasswordsMatch(null, null), isTrue);
    });
  });
}
