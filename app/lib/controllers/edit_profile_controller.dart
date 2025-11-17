import 'package:nomnom_safe/providers/auth_state_provider.dart';

class EditProfileController {
  final AuthStateProvider authProvider;

  EditProfileController({required this.authProvider});

  Future<String?> saveProfileChanges({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    List<String>? allergies,
  }) async {
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    try {
      await authProvider.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        allergies: allergies,
      );
      await authProvider.loadCurrentUser();
      return null; // success
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<bool> verifyCurrentPassword(String password) async {
    return await authProvider.reauthenticate(password);
  }

  Future<String?> updatePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      return 'Passwords do not match';
    }

    try {
      await authProvider.updatePassword(newPassword);
      return null; // success
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}
