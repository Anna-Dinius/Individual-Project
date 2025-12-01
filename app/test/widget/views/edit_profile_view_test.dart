import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/views/edit_profile_view.dart';

void main() {
  testWidgets('EditProfileView renders inputs and buttons', (tester) async {
    final formKey = GlobalKey<FormState>();
    final fn = TextEditingController();
    final ln = TextEditingController();
    final email = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditProfileView(
            formKey: formKey,
            firstNameController: fn,
            lastNameController: ln,
            emailController: email,
            onSave: () {},
            onChangePassword: () {},
            isLoading: false,
            allAllergenLabels: const ['A', 'B'],
            selectedAllergenLabels: const {'A'},
            onAllergenChanged: (id, checked) {},
          ),
        ),
      ),
    );

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
  });
}
