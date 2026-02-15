enum OriginalLanguage {
  english('English'),
  russian('Russian'),
  hindi('Hindi'),
  french('French'),
  japanese('Japanese'),
  chinese('Chinese'),
  spanish('Spanish'),
  german('German'),
  arabic('Arabic'),
  italian('Italian'),
  korean('Korean'),
  other('Other');

  const OriginalLanguage(this.clientValue);

  final String clientValue;
}
