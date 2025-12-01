import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/utils/form_validation_utils.dart';

void main() {
  group('FormValidators', () {
    test('requiredField returns message when null or empty', () {
      expect(
        FormValidators.requiredField(null, fieldName: 'Name'),
        'Name is required',
      );
      expect(
        FormValidators.requiredField('   ', fieldName: 'Name'),
        'Name is required',
      );
      expect(FormValidators.requiredField('x', fieldName: 'Name'), isNull);
    });

    test('email validator checks presence and @', () {
      expect(FormValidators.email(null), 'Email is required');
      expect(FormValidators.email('no-at'), 'Enter a valid email');
      expect(FormValidators.email('a@b.com'), isNull);
    });

    test('password validator checks presence and length', () {
      expect(FormValidators.password(null), 'Password is required');
      expect(
        FormValidators.password('123'),
        'Password must be at least 6 characters',
      );
      expect(FormValidators.password('123456'), isNull);
    });

    test('confirmPassword validator compares to original', () {
      expect(
        FormValidators.confirmPassword(null, 'orig'),
        'Confirm password is required',
      );
      expect(
        FormValidators.confirmPassword('nope', 'orig'),
        'Passwords do not match',
      );
      expect(FormValidators.confirmPassword('orig', 'orig'), isNull);
    });
  });
}
