import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/book_entity.dart';
import '../entities/scan/scanned_book_entity.dart';

abstract class BookRepository {
  String generateId();
  Future<List<BookEntity>> fetchBooks();
  Future<BookEntity?> fetchBookById(String id);
  Stream<List<BookEntity>> watchBooks();
  Future<void> addBook(BookEntity book, {WriteBatch? batch});
  Future<void> editBook(BookEntity book, {WriteBatch? batch});
  Future<void> removeBook(String id, {WriteBatch? batch});
  Future<BookEntity> upsertBook(
    BookEntity book,
    Map<String, String> sequenceIdToVolume,
    bool isEdit,
    bool applyToWorks, {
    WriteBatch? batch,
  });
  Future<ScannedBookEntity> scanBookCover(Uint8List imageBytes);
}
