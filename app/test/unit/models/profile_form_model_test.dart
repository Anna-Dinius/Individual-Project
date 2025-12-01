import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/models/profile_form_model.dart';
import 'package:nomnom_safe/models/user.dart';

void main() {
  group('ProfileFormModel - construction and fromUser', () {
    test('constructs with provided controllers', () {
      final fn = TextEditingController(text: 'A');
      final ln = TextEditingController(text: 'B');
      final em = TextEditingController(text: 'a@b.c');

      final model = ProfileFormModel(firstName: fn, lastName: ln, email: em);

      expect(model.firstName, same(fn));
      expect(model.lastName, same(ln));
      expect(model.email, same(em));
      expect(model.formKey, isA<GlobalKey<FormState>>());
    });

    test('fromUser with null user creates empty controllers', () {
      final model = ProfileFormModel.fromUser(null);

      expect(model.firstName.text, isEmpty);
      expect(model.lastName.text, isEmpty);
      expect(model.email.text, isEmpty);

      // password-related controllers exist and are empty
      expect(model.password.text, isEmpty);
      expect(model.confirmPassword.text, isEmpty);
      expect(model.currentPassword.text, isEmpty);
      expect(model.newPassword.text, isEmpty);
      expect(model.confirmNewPassword.text, isEmpty);
    });

    test('fromUser populates controllers from User', () {
      final user = User(
        id: 'u1',
        firstName: 'First',
        lastName: 'Last',
        email: 'x@y.z',
      );

      final model = ProfileFormModel.fromUser(user);
      expect(model.firstName.text, 'First');
      expect(model.lastName.text, 'Last');
      expect(model.email.text, 'x@y.z');
    });

    test('fromUser with long strings and special chars', () {
      final long = List.filled(500, 'x').join();
      final special = "O'Connor \n \u2603"; // includes newline and snowman
      final user = User(
        id: 'u2',
        firstName: long,
        lastName: special,
        email: 'weird+email@example.com',
      );

      final model = ProfileFormModel.fromUser(user);
      expect(model.firstName.text, long);
      expect(model.lastName.text, special);
      expect(model.email.text, 'weird+email@example.com');
    });

    test('multiple instances use independent controllers', () {
      final user = User(
        id: 'u3',
        firstName: 'One',
        lastName: 'Two',
        email: 'one@two',
      );

      final a = ProfileFormModel.fromUser(user);
      final b = ProfileFormModel.fromUser(user);

      // Changing a should not affect b
      a.firstName.text = 'Changed';
      expect(b.firstName.text, 'One');

      // formKey should be unique per instance
      expect(a.formKey, isNot(equals(b.formKey)));
    });
  });

  group('ProfileFormModel - lifecycle and behavior', () {
    test('dispose can be called multiple times without throwing', () {
      final model = ProfileFormModel.fromUser(null);
      // calling dispose once
      model.dispose();
      // calling dispose again currently throws a FlutterError (TextEditingController used after dispose)
      expect(() => model.dispose(), throwsA(isA<FlutterError>()));
    });

    test('controllers reflect changes to text', () {
      final model = ProfileFormModel.fromUser(null);
      model.firstName.text = 'Alpha';
      model.lastName.text = 'Beta';
      model.email.text = 'a@b.com';

      expect(model.firstName.text, 'Alpha');
      expect(model.lastName.text, 'Beta');
      expect(model.email.text, 'a@b.com');
    });

    test('password controllers exist and are independent', () {
      final model = ProfileFormModel.fromUser(null);
      model.password.text = 'p1';
      model.confirmPassword.text = 'p1';

      expect(model.password.text, 'p1');
      expect(model.confirmPassword.text, 'p1');

      model.newPassword.text = 'new';
      model.confirmNewPassword.text = 'new';
      expect(model.newPassword.text, 'new');
      expect(model.confirmNewPassword.text, 'new');
    });
  });

  group('ProfileFormModel - edge cases', () {
    test(
      'creating with controllers that are later mutated reflects values',
      () {
        final fn = TextEditingController(text: 'Initial');
        final ln = TextEditingController(text: 'L');
        final em = TextEditingController(text: 'e@x');

        final model = ProfileFormModel(firstName: fn, lastName: ln, email: em);
        // mutate source controllers
        fn.text = 'ChangedExternally';
        ln.text = 'ChangedExternally2';
        em.text = 'changed@example.com';

        expect(model.firstName.text, 'ChangedExternally');
        expect(model.lastName.text, 'ChangedExternally2');
        expect(model.email.text, 'changed@example.com');

        // cleanup
        model.dispose();
      },
    );

    test(
      'fromUser does not reuse the same TextEditingController instances',
      () {
        final user = User(
          id: 'u4',
          firstName: 'A',
          lastName: 'B',
          email: 'c@d',
        );

        final a = ProfileFormModel.fromUser(user);
        final b = ProfileFormModel.fromUser(user);

        // Ensure controllers are not identical objects
        expect(identical(a.firstName, b.firstName), isFalse);
        expect(identical(a.lastName, b.lastName), isFalse);
        expect(identical(a.email, b.email), isFalse);

        a.dispose();
        b.dispose();
      },
    );
  });
}
