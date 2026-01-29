enum CompilationType {
  single('Single', 'A single book'),
  collection('Collection', 'A collection of items by single author'),
  anthology('Anthology', 'A collection of items by multiple authors');

  const CompilationType(this.clientValue, this.helpText);

  final String clientValue;
  final String helpText;
}
