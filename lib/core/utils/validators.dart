/// A collection of validators for form inputs throughout the app.
class Validators {
  Validators._();

  /// Validates a Facebook URL.
  ///
  /// Returns null if valid, or an error message if invalid.
  /// Accepts formats like:
  /// - https://www.facebook.com/username
  /// - https://facebook.com/username
  /// - https://www.facebook.com/profile.php?id=12345
  ///
  /// Example valid URL: https://www.facebook.com/chandana.mendis.397
  static String? validateFacebookUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final String trimmed = value.trim();

    // Pattern for Facebook URL: (https://)?(www.)?facebook.com/{path}
    // Path can contain letters, numbers, periods, hyphens, slashes, and query params
    const String pattern =
        r'^(https?:\/\/)?(www\.)?(facebook\.com|fb\.com)\/[a-zA-Z0-9._\-\/]+(\?.*)?$';
    final RegExp regExp = RegExp(pattern);

    if (!regExp.hasMatch(trimmed)) {
      return 'Invalid Facebook URL';
    }

    return null;
  }

  /// Validates a general website URL.
  ///
  /// Returns null if valid, or an error message if invalid.
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

  /// Validates a Sri Lankan phone number.
  ///
  /// Returns null if valid, or an error message if invalid.
  /// Accepts formats like:
  /// - +94 XX XXXXXXX or +94XXXXXXXXX
  /// - 0XX XXXXXXX or 0XXXXXXXXX
  /// - With or without spaces/dashes
  ///
  /// Sri Lankan mobile prefixes: 70, 71, 72, 74, 75, 76, 77, 78
  /// Sri Lankan landline prefixes: 11, 21, 23, 24, 25, 26, 27, 31, 32, etc.
  static String? validateSriLankanPhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove all spaces, dashes, and parentheses
    final String cleaned = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Pattern for Sri Lankan phone numbers:
    // +94XXXXXXXXX (12 digits with +) or 0XXXXXXXXX (10 digits starting with 0)
    const String pattern = r'^(\+94[0-9]{9}|0[0-9]{9})$';
    final RegExp regExp = RegExp(pattern);

    if (!regExp.hasMatch(cleaned)) {
      return 'Invalid phone number. Use format: +94 XX XXXXXXX or 0XX XXXXXXX';
    }

    return null;
  }
}
