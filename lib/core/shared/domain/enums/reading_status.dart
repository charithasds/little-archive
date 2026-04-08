/// Represents the user's current progress in reading a specific work.
enum ReadingStatus {
  /// The work has not been started yet.
  notStarted('Not Started'),

  /// The work is currently being read.
  reading('Reading'),

  /// The user has temporarily stopped reading the work.
  paused('Paused'),

  /// The user has finished reading the work.
  completed('Completed'),

  /// The user has decided not to finish the work.
  abandoned('Abandoned');

  const ReadingStatus(this.clientValue);

  /// The human-readable string representation of the reading status.
  final String clientValue;
}
