/// Represents the language in which a work is written or published.
enum Language {
  /// The Sinhala language.
  sinhala('Sinhala'),

  /// The English language.
  english('English'),

  /// The Tamil language.
  tamil('Tamil'),

  /// Languages not explicitly listed.
  other('Other');

  const Language(this.clientValue);

  /// The human-readable string representation of the language.
  final String clientValue;
}
