import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

class GetBooksUseCase {
  const GetBooksUseCase(this.repository);
  final BookRepository repository;

  Future<List<BookEntity>> call(String userId) => repository.getBooks(userId);
}

class WatchBooksUseCase {
  const WatchBooksUseCase(this.repository);
  final BookRepository repository;

  Stream<List<BookEntity>> call(String userId) => repository.watchBooks(userId);
}

class GetBookByIdUseCase {
  const GetBookByIdUseCase(this.repository);
  final BookRepository repository;

  Future<BookEntity?> call(String id) => repository.getBookById(id);
}

class AddBookUseCase {
  const AddBookUseCase(this.repository);
  final BookRepository repository;

  Future<void> call(BookEntity book) => repository.addBook(book);
}

class UpdateBookUseCase {
  const UpdateBookUseCase(this.repository);
  final BookRepository repository;

  Future<void> call(BookEntity book) => repository.updateBook(book);
}

class DeleteBookUseCase {
  const DeleteBookUseCase(this.repository);
  final BookRepository repository;

  Future<void> call(String id) => repository.deleteBook(id);
}
