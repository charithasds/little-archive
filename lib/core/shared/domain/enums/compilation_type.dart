/// Defines how a book or publication is structured in terms of its content authorship.
enum CompilationType {
  /// A book containing a single primary work.
  single('Single', 'A single book'),

  /// A collection of works written by the same author.
  collection('Collection', 'A collection of items by single author'),

  /// A collection of works written by multiple different authors.
  anthology('Anthology', 'A collection of items by multiple authors');

  const CompilationType(this.clientValue, this.helpText);

  /// The human-readable string representation of the compilation type.
  final String clientValue;

  /// A descriptive text helping users understand the type.
  final String helpText;
}
