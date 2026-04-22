import '../entities/book_entity.dart';

abstract class BookRepository {
  String generateId();
  Future<List<BookEntity>> fetchBooks();
  Future<BookEntity?> fetchBookById(String id);
  Stream<List<BookEntity>> watchBooks();
  Future<void> addBook(BookEntity book);
  Future<void> editBook(BookEntity book);
  Future<void> removeBook(String id);
}
