import 'package:flutter/material.dart';
import 'package:nomnom_safe/controllers/edit_profile_controller.dart';
import 'package:nomnom_safe/models/profile_form_model.dart';
import 'package:nomnom_safe/views/edit_profile_view.dart';
import 'package:nomnom_safe/views/update_password_view.dart';
import 'package:nomnom_safe/views/verify_current_password_view.dart';

class EditProfileBody extends StatelessWidget {
  final EditProfileController controller;
  final ProfileFormModel formModel;

  const EditProfileBody({
    super.key,
    required this.controller,
    required this.formModel,
  });

  @override
  Widget build(BuildContext context) {
    switch (controller.viewState) {
      case ProfileViewState.editProfile:
        return _buildEditProfileView(context);
      case ProfileViewState.verifyCurrentPassword:
        return _buildVerifyPasswordView();
      case ProfileViewState.updatePassword:
        return _buildUpdatePasswordView();
    }
  }

  Widget _buildEditProfileView(BuildContext context) {
    return EditProfileView(
      formKey: formModel.formKey,
      firstNameController: formModel.firstName,
      lastNameController: formModel.lastName,
      emailController: formModel.email,
      onSave: () async {
        await controller.saveChanges(
          firstName: formModel.firstName.text.trim(),
          lastName: formModel.lastName.text.trim(),
          email: formModel.email.text.trim(),
          password: formModel.password.text,
          confirmPassword: formModel.confirmPassword.text,
        );

        if (controller.errorMessage == null && context.mounted) {
          Navigator.of(context).pop(true); // return success flag
        }
      },
      onChangePassword: controller.goToVerifyPassword,
      isLoading: controller.isLoading,
      allAllergenLabels: controller.allergenIdToLabel.values.toList(),
      selectedAllergenLabels: controller.selectedAllergenLabels,
      onAllergenChanged: controller.toggleAllergen,
    );
  }

  Widget _buildVerifyPasswordView() {
    return VerifyCurrentPasswordView(
      controller: formModel.currentPassword,
      isVisible: controller.arePasswordsVisible,
      onToggleVisibility: controller.togglePasswordVisibility,
      onContinue: () =>
          controller.verifyCurrentPassword(formModel.currentPassword.text),
      isLoading: controller.isLoading,
      errorMessage: controller.errorMessage,
    );
  }

  Widget _buildUpdatePasswordView() {
    return UpdatePasswordView(
      formKey: formModel.formKey,
      newPasswordController: formModel.newPassword,
      confirmPasswordController: formModel.confirmNewPassword,
      isVisible: controller.arePasswordsVisible,
      onToggleVisibility: controller.togglePasswordVisibility,
      onBack: controller.goBackToEditProfile,
      onSubmit: () => controller.updatePassword(
        newPassword: formModel.newPassword.text,
        confirmPassword: formModel.confirmNewPassword.text,
      ),
      isLoading: controller.isLoading,
      errorMessage: controller.errorMessage,
    );
  }
}
