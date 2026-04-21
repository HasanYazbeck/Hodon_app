/// Centralised form validation logic.
class AppValidators {
  AppValidators._();

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Please enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) return 'Please enter a valid phone number';
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) return 'Please enter the OTP code';
    if (value.length != 6) return 'Please enter all 6 digits';
    return null;
  }

  static String? hourlyRate(String? value) {
    if (value == null || value.isEmpty) return 'Hourly rate is required';
    final rate = double.tryParse(value);
    if (rate == null) return 'Please enter a valid number';
    if (rate < 5) return 'Minimum rate is \$5/hr';
    return null;
  }

  static String? minLength(String? value, int min, {String fieldName = 'This field'}) {
    if (value == null || value.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String fieldName = 'This field'}) {
    if (value != null && value.trim().length > max) {
      return '$fieldName must not exceed $max characters';
    }
    return null;
  }
}

