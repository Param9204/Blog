String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email cannot be empty';
  }
  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!regex.hasMatch(value)) {
    return 'Enter a valid email';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password cannot be empty';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters long';
  }
  return null;
}
