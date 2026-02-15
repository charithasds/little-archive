enum WorkType {
  shortStory('Short Story'),
  novella('Novella'),
  novelette('Novelette'),
  flashFiction('Flash Fiction'),
  poem('Poem'),
  essay('Essay'),
  article('Article'),
  entry('Entry'),
  preface('Preface'),
  appendix('Appendix');

  const WorkType(this.clientValue);

  final String clientValue;
}
