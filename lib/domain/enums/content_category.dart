enum ContentCategory {
  novel('Novel', 'A full-length fictional work, typically over 40,000 words'),
  novella('Novella', 'A standalone story shorter than a novel but longer than a short story'),
  shortStory('Short Story', 'A brief work of fiction, usually found in collections or anthologies'),
  essay('Essay', 'A short literary composition on a particular theme or subject'),
  poem('Poem', 'A piece of writing that uses imaginative and rhetorical language'),
  play('Play', 'A dramatic work intended for performance, such as a script'),
  screenplay('Screenplay', 'The script of a movie or television show'),
  article('Article', 'A non-fiction piece originally written for a periodical or journal'),
  letter('Letter', 'Personal or formal correspondence included for literary value'),
  excerpt('Excerpt', 'A specific passage or chapter taken from a larger work');

  const ContentCategory(this.clientValue, this.helpText);
  final String clientValue;
  final String helpText;
}
