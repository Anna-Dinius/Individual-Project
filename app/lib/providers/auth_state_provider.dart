import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

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
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    List<String>? allergies,
  }) async {
    await _authService.updateUserProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      allergies: allergies,
    );
    notifyListeners();
  }

  /// Get current user (for profile display)
  dynamic get currentUser => _authService.currentUser;
}
