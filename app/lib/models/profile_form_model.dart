import 'package:flutter/material.dart';
import 'package:nomnom_safe/models/user.dart';

class ProfileFormModel {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController email;
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController currentPassword = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmNewPassword = TextEditingController();

  ProfileFormModel({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  /// Factory constructor to initialize controllers from a User object
  factory ProfileFormModel.fromUser(User? user) {
    if (user == null) {
      return ProfileFormModel(
        firstName: TextEditingController(),
        lastName: TextEditingController(),
        email: TextEditingController(),
      );
    }
    return ProfileFormModel(
      firstName: TextEditingController(text: user.firstName),
      lastName: TextEditingController(text: user.lastName),
      email: TextEditingController(text: user.email),
    );
  }

  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    currentPassword.dispose();
    newPassword.dispose();
    confirmNewPassword.dispose();
  }
}
