/// A utility class containing static methods for validating form inputs.
///
/// These validators return a [String] error message if validation fails,
/// or `null` if the input is valid.
class Validators {
  Validators._();

  /// Validates that a string is a valid Facebook or FB URL.
  ///
  /// Supports:
  /// - https://www.facebook.com/username
  /// - http://facebook.com/username
  /// - fb.com/username
  static String? validateFacebookUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final String trimmed = value.trim();

    const String pattern =
        r'^(https?:\/\/)?(www\.)?(facebook\.com|fb\.com)\/[a-zA-Z0-9._\-\/]+(\?.*)?$';
    final RegExp regExp = RegExp(pattern);

    if (!regExp.hasMatch(trimmed)) {
      return 'Invalid Facebook URL';
    }

    return null;
  }

  /// Validates that a string follows a standard email format.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final RegExp regExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

    if (!regExp.hasMatch(value.trim())) {
      return 'Invalid email address';
    }

    return null;
  }

  /// Validates that a string is a properly formatted website URL.
  static String? validateWebsiteUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    const String pattern =
        r'^(https?:\/\/)?([a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}(\/[^\s]*)?$';
    final RegExp regExp = RegExp(pattern);

    if (!regExp.hasMatch(value.trim())) {
      return 'Invalid URL format';
    }

    return null;
  }

  /// Validates that a string is a valid Sri Lankan phone number.
  ///
  /// Supports:
  /// - Local format: 071 234 5678
  /// - International format: +94 71 234 5678
  static String? validateSriLankanPhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final String cleaned = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');

    const String pattern = r'^(\+94[0-9]{9}|0[0-9]{9})$';
    final RegExp regExp = RegExp(pattern);

    if (!regExp.hasMatch(cleaned)) {
      return 'Invalid phone number. Use format: +94 XX XXXXXXX or 0XX XXXXXXX';
    }

    return null;
  }
}
