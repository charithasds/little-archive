enum ReadingStatus {
  notStarted('Not Started'),
  reading('Reading'),
  completed('Completed'),
  paused('Paused'),
  abandoned('Abandoned');

  const ReadingStatus(this.clientValue);

  final String clientValue;
}
