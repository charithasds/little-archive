enum ContentCategory {
  novel('Novel'),

  shortStory('Short Story'),

  novella('Novella'),

  novelette('Novelette'),

  flashFiction('Flash Fiction'),

  play('Play'),

  screenplay('Screenplay'),

  poem('Poem'),

  memoir('Memoir'),

  speech('Speech'),

  essay('Essay'),

  article('Article'),

  entry('Entry'),

  foreword('Foreword'),

  afterword('Afterword'),

  appendix('Appendix');

  const ContentCategory(this.clientValue);

  final String clientValue;
}
