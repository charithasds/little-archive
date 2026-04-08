/// Represents the classification/format of a literary work.
enum ContentCategory {
  /// A long-form fictional narrative.
  novel('Novel'),

  /// A brief work of fiction, typically shorter than a novella.
  shortStory('Short Story'),

  /// A work of narrative fiction longer than a short story but shorter than a novel.
  novella('Novella'),

  /// A work of narrative fiction between a short story and a novella in length.
  novelette('Novelette'),

  /// Extremely short fiction, often under 1,000 words.
  flashFiction('Flash Fiction'),

  /// A dramatic work intended for performance on stage.
  play('Play'),

  /// A script written for a film or television show.
  screenplay('Screenplay'),

  /// A literary work that uses aesthetic and rhythmic qualities of language.
  poem('Poem'),

  /// A historical account or biography written from personal knowledge.
  memoir('Memoir'),

  /// A formal address or discourse delivered to an audience.
  speech('Speech'),

  /// A short piece of writing on a particular subject.
  essay('Essay'),

  /// A non-fictional piece of writing that forms an independent part of a publication.
  article('Article'),

  /// A single item of information, such as in a diary or encyclopedia.
  entry('Entry'),

  /// A short introduction to a book, typically by someone other than the author.
  foreword('Foreword'),

  /// A concluding section in a book, often providing a reflection or subtext.
  afterword('Afterword'),

  /// Supplementary material at the end of a document or book.
  appendix('Appendix');

  const ContentCategory(this.clientValue);

  /// The human-readable string representation of the category.
  final String clientValue;
}
