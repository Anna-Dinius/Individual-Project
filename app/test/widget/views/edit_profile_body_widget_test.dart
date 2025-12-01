import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/views/edit_profile_body.dart';
import 'package:nomnom_safe/models/profile_form_model.dart';
import 'package:nomnom_safe/controllers/edit_profile_controller.dart';
import 'package:nomnom_safe/providers/auth_state_provider.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/models/user.dart';

class _NoopAuth extends AuthStateProvider {
  _NoopAuth() : super();

  @override
  User? get currentUser => null;
}

class _NoopAllergen extends AllergenService {
  _NoopAllergen() : super(Object());

  @override
  Future<Map<String, String>> getAllergenIdToLabelMap() async => {};

  @override
  Future<Map<String, String>> getAllergenLabelToIdMap() async => {};

  @override
  Future<List<String>> idsToLabels(List<String> ids) async => [];
}

void main() {
  testWidgets('EditProfileBody widget builds for edit profile state', (
    tester,
  ) async {
    final controller = EditProfileController(
      authProvider: _NoopAuth(),
      allergenService: _NoopAllergen(),
    );
    controller.viewState = ProfileViewState.editProfile;
    final formModel = ProfileFormModel(
      firstName: TextEditingController(),
      lastName: TextEditingController(),
      email: TextEditingController(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditProfileBody(controller: controller, formModel: formModel),
        ),
      ),
    );

    expect(find.text('Edit Profile'), findsOneWidget);
  });
}
