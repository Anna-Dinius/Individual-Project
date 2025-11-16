String? validateEmailFormat(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  if (!value.contains('@') || !value.contains('.')) {
    return 'Enter a valid email';
  }
  return null;
}

String? validatePasswordFormat(String? password) {
  if (password == null || password.trim().isEmpty) {
    return 'Required';
  }
  if (password.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

bool validatePasswordsMatch(String? password, String? confirmPassword) {
  if (password == confirmPassword) {
    return true;
  }
  return false;
}
