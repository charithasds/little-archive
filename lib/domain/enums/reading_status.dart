enum ReadingStatus {
  notStarted('Not Started'),
  reading('Reading'),
  paused('Paused'),
  completed('Completed'),
  abandoned('Abandoned');

  const ReadingStatus(this.clientValue);
  final String clientValue;
}
