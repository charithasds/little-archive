import 'dart:typed_data';

import '../entities/book_entity.dart';
import '../entities/scan/scanned_book_entity.dart';

abstract class BookRepository {
  String generateId();
  Future<List<BookEntity>> fetchBooks();
  Future<BookEntity?> fetchBookById(String id);
  Stream<List<BookEntity>> watchBooks();
  Future<void> addBook(BookEntity book);
  Future<void> editBook(BookEntity book, {BookEntity? oldBook});
  Future<void> removeBook(String id);
  Future<BookEntity> upsertBook(
    BookEntity book,
    Map<String, String> sequenceIdToVolume,
    bool isEdit,
    bool applyToWorks,
  );
  Future<ScannedBookEntity> scanBookCover(Uint8List imageBytes);
}
