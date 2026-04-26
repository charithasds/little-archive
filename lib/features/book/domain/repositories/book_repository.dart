import 'dart:typed_data';

import '../entities/book_entity.dart';
import '../entities/scanned_book_entity.dart';

abstract class BookRepository {
  String generateId();
  Future<List<BookEntity>> fetchBooks();
  Future<BookEntity?> fetchBookById(String id);
  Stream<List<BookEntity>> watchBooks();
  Future<void> addBook(BookEntity book);
  Future<void> editBook(BookEntity book);
  Future<void> removeBook(String id);
  Future<int> fetchCount();
  Future<ScannedBookEntity> scanBookCover(Uint8List imageBytes);
}
