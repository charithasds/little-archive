enum CompilationType {
  standalone('Standalone', 'One book, one story'),
  collection('Collection', 'One book, multiple stories by the same author'),
  anthology('Anthology', 'One book, multiple stories by different authors'),
  omnibus('Omnibus', 'One book, multiple previously published novels');

  const CompilationType(this.clientValue, this.helpText);
  final String clientValue;
  final String helpText;
}
