import '../../../book/domain/entities/book_entity.dart';

/// Data class carrying everything needed to render one row in the sheet.
class BookFairExportEntry {
  const BookFairExportEntry({
    required this.book,
    required this.creators,
    required this.publisherName,
    required this.halls,
    required this.stallNo,
    required this.stallName,
  });

  final BookEntity book;
  final String creators;
  final String publisherName;
  final List<String> halls;
  final String stallNo;
  final String stallName;
}

/// Result returned after a sync (pull) operation.
class BookFairSyncResult {
  const BookFairSyncResult({
    required this.updatedBookTitles,
    required this.conflictBookTitles,
  });

  final List<String> updatedBookTitles;
  final List<String> conflictBookTitles;
}
