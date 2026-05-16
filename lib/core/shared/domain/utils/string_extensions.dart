extension StringCleaning on String? {
  /// Cleans dummy data like "N/A", "Unknown", etc.
  String? get cleanDummyData {
    if (this == null) {
      return null;
    }
    final String trimmed = this!.trim();
    final String upper = trimmed.toUpperCase();

    if (upper == 'N/A' ||
        upper == 'NA' ||
        upper == 'UNKNOWN' ||
        upper == 'NONE' ||
        trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}

extension StringFormatting on String {
  /// Converts string to Title Case
  String toTitleCase() {
    if (isEmpty) {
      return this;
    }

    return split(RegExp(r'\s+'))
        .map((String word) {
          if (word.isEmpty) {
            return word;
          }

          if (word.length == 1) {
            return word.toUpperCase();
          }

          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
