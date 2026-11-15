enum Genre {
  action(
    'Action & Adventure',
    'Stories defined by risk, physical danger, and fast-paced sequences',
  ),
  biography('Biography & Memoir', 'An account of a person’s life written by themselves or another'),
  crime(
    'Crime & Mystery',
    'Focuses on the investigation of a crime, often featuring detectives or suspense',
  ),
  fantasy(
    'Fantasy',
    'Speculative fiction involving magical elements, supernatural worlds, or mythology',
  ),
  fiction(
    'Fiction',
    'Fictional narratives that explore human experiences, emotions, and societal themes through imagination',
  ),
  historical(
    'Historical Fiction',
    'Narratives set in the past that capture the spirit and manners of a historical period',
  ),
  horror(
    'Horror',
    'Fiction intended to frighten, scare, or startle by inducing feelings of horror and terror',
  ),
  literary(
    'Literary Fiction',
    'Works that offer intellectual or social commentary, often focusing on style and character depth',
  ),
  nature(
    'Nature & Wildlife',
    'Books focused on the natural world, animals, and environmental observation',
  ),
  nonFiction(
    'General Non-Fiction',
    'Informational books covering facts, history, philosophy, or true events',
  ),
  poetry(
    'Poetry',
    'Literary work in which special intensity is given to the expression of feelings',
  ),
  romance(
    'Romance',
    'Stories centered on primary romantic relationships and their emotional development',
  ),
  sciFi(
    'Science Fiction',
    'Speculative fiction dealing with futuristic concepts, technology, and space exploration',
  ),
  technical(
    'Technical & Development',
    'Specialized books on programming, engineering, or scientific documentation',
  ),
  thriller(
    'Thriller & Suspense',
    'Fast-paced plots characterized by high stakes, tension, and excitement',
  ),
  travel(
    'Travel & Geography',
    'Accounts of journeys, descriptions of locations, and cultural explorations',
  );

  const Genre(this.clientValue, this.helpText);
  final String clientValue;
  final String helpText;
}
