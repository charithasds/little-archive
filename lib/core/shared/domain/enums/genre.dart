/// Represents the artistic category or style of a literary work.
enum Genre {
  /// Fiction involving magical elements and imaginary worlds.
  fantasy('Fantasy'),

  /// Fiction dealing with imaginative concepts such as futuristic science and technology.
  sciFi('Sci-Fi'),

  /// Fiction involving a puzzling crime or event that needs solving.
  mystery('Mystery'),

  /// Fiction focusing on romantic relationships and love.
  romance('Romance'),

  /// Non-fiction or fiction based on historical events and eras.
  history('History'),

  /// Fiction intended to frighten or shock.
  horror('Horror'),

  /// Fiction designed to keep the reader in suspense or excitement.
  thriller('Thriller'),

  /// Categories not explicitly listed.
  other('Other');

  const Genre(this.clientValue);

  /// The human-readable string representation of the genre.
  final String clientValue;
}
