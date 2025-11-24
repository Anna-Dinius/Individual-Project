import 'package:flutter/foundation.dart';
import 'package:nomnom_safe/services/auth_service.dart';
import 'package:nomnom_safe/models/user.dart';

/// AuthStateProvider notifies listeners when authentication state changes
class AuthStateProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool get isSignedIn => _authService.isSignedIn;

  /// Sign up and notify listeners
  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    List<String>? allergies,
  }) async {
    await _authService.signUp(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      allergies: allergies,
    );
    notifyListeners();
  }

  /// Sign in and notify listeners
  Future<void> signIn({required String email, required String password}) async {
    await _authService.signIn(email: email, password: password);
    notifyListeners();
  }

  /// Sign out and notify listeners
  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }

  /// Update profile and notify listeners
  Future<String?> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    List<String>? allergies,
  }) async {
    final error = await _authService.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      allergies: allergies,
    );
    notifyListeners();
    return error;
  }

  Future<void> loadCurrentUser() async {
    await _authService.loadCurrentUser();
    notifyListeners();
  }

  /// Verify current password
  Future<bool> verifyPassword(String password) async {
    try {
      return await _authService.verifyPassword(password);
    } catch (_) {
      return false;
    }
  }

  /// Update password with confirmation
  Future<String?> updatePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    final error = await _authService.updatePassword(
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    notifyListeners();
    return error;
  }

  Future<void> deleteAccount({required String password}) async {
    final success = await _authService.verifyPassword(password);
    if (!success) {
      throw Exception('Please log in again before deleting your account.');
    }

    await _authService.deleteAccount(); // your backend call
    notifyListeners();
  }

  /// Get current user (for profile display)
  User? get currentUser => _authService.currentUser;
}
