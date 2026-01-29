import '../entities/book_entity.dart';

abstract class BookRepository {
  Future<List<BookEntity>> getBooks(String userId);
  Future<BookEntity?> getBookById(String id);
  Future<void> addBook(BookEntity book);
  Future<void> updateBook(BookEntity book);
  Future<void> deleteBook(String id);
  Stream<List<BookEntity>> watchBooks(String userId);
}
