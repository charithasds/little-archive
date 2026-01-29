enum Genre {
  fantasy('Fantasy'),
  sciFi('Sci-Fi'),
  mystery('Mystery'),
  romance('Romance'),
  history('History'),
  horror('Horror'),
  thriller('Thriller'),
  other('Other');

  const Genre(this.clientValue);

  final String clientValue;
}
