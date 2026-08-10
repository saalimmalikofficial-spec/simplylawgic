// lib/utils/validators.dart (Add phone validator)
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // Phone validator
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any non-digit characters
    final phoneDigits = value.replaceAll(RegExp(r'\D'), '');

    if (phoneDigits.length != 10) {
      return 'Please enter a valid 10-digit phone number';
    }

    return null;
  }

  // OTP validator
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (value.length != 4) {
      return 'OTP must be 4 digits';
    }

    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }

    return null;
  }
}