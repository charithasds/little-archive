/// Represents the original language a work was written in before translation.
enum OriginalLanguage {
  /// The English language.
  english('English'),

  /// The Russian language.
  russian('Russian'),

  /// The Hindi language.
  hindi('Hindi'),

  /// The French language.
  french('French'),

  /// The Japanese language.
  japanese('Japanese'),

  /// The Chinese language.
  chinese('Chinese'),

  /// The Spanish language.
  spanish('Spanish'),

  /// The German language.
  german('German'),

  /// The Arabic language.
  arabic('Arabic'),

  /// The Italian language.
  italian('Italian'),

  /// The Korean language.
  korean('Korean'),

  /// Languages not explicitly listed.
  other('Other');

  const OriginalLanguage(this.clientValue);

  /// The human-readable string representation of the original language.
  final String clientValue;
}
