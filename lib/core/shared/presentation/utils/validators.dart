class Validators {
  Validators._();

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

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final RegExp regExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!regExp.hasMatch(value.trim())) {
      return 'Invalid email address';
    }

    return null;
  }

  static String? validateWebsiteUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    const String pattern =
        r'^(https?:\/\/)?([a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5})(:[0-9]{1,5})?(\/.*)?$';
    final RegExp regExp = RegExp(pattern, caseSensitive: false);

    if (!regExp.hasMatch(value.trim())) {
      return 'Invalid Website URL';
    }

    return null;
  }

  static String? validateSriLankanPhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final String cleaned = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    const String pattern = r'^(\+94[0-9]{9}|0[0-9]{9})$';
    final RegExp regExp = RegExp(pattern);

    if (!regExp.hasMatch(cleaned)) {
      return 'Invalid phone number. Use format: +94 XX XXXXXXX or 0XX XXXXXXX';
    }

    return null;
  }

  static String? validatePositiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final double? number = double.tryParse(value);

    if (number == null || number <= 0) {
      return 'Enter a valid positive number';
    }

    return null;
  }

  static String? validateIsbn(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final String clean = value.replaceAll(RegExp(r'[-\s]'), '').toUpperCase();

    if (clean.length != 10 && clean.length != 13) {
      return 'Enter 10 or 13 digits';
    }

    if (clean.length == 10) {
      if (!RegExp(r'^\d{9}[\dX]$').hasMatch(clean)) {
        return 'Invalid ISBN-10 format';
      }
    } else {
      if (!RegExp(r'^\d{13}$').hasMatch(clean)) {
        return 'Invalid ISBN-13 format';
      }
    }

    return null;
  }

  static bool isValidIsbn10(String value) {
    final String clean = value.replaceAll(RegExp(r'[-\s]'), '').toUpperCase();
    if (clean.length != 10) {
      return false;
    }
    if (!RegExp(r'^\d{9}[\dX]$').hasMatch(clean)) {
      return false;
    }
    int sum = 0;
    for (int i = 0; i < 10; i++) {
      final String char = clean[i];
      final int val = char == 'X' ? 10 : int.parse(char);
      sum += val * (10 - i);
    }
    return sum % 11 == 0;
  }

  static bool isValidIsbn13(String value) {
    final String clean = value.replaceAll(RegExp(r'[-\s]'), '').toUpperCase();
    if (clean.length != 13) {
      return false;
    }
    if (!RegExp(r'^\d{13}$').hasMatch(clean)) {
      return false;
    }
    int sum = 0;
    for (int i = 0; i < 13; i++) {
      final int val = int.parse(clean[i]);
      final int weight = i.isEven ? 1 : 3;
      sum += val * weight;
    }
    return sum % 10 == 0;
  }

  static String formatIsbn(String isbn) {
    final String clean = isbn
        .replaceAll(RegExp(r'[^0-9X]', caseSensitive: false), '')
        .toUpperCase();

    if (clean.length == 13) {
      if (clean.startsWith('978') || clean.startsWith('979')) {
        return '${clean.substring(0, 3)}-${clean.substring(3, 4)}-${clean.substring(4, 7)}-${clean.substring(7, 12)}-${clean.substring(12)}';
      }

      return clean;
    } else if (clean.length == 10) {
      return '${clean.substring(0, 1)}-${clean.substring(1, 4)}-${clean.substring(4, 9)}-${clean.substring(9)}';
    }

    return isbn;
  }
}
