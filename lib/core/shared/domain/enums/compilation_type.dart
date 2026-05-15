enum CompilationType {
  single('Single', 'One book, one story'),
  multiple('Multiple', 'One book, multiple stories');

  const CompilationType(this.clientValue, this.helpText);
  final String clientValue;
  final String helpText;
}
