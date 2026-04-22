import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

class FetchBooksUseCase {
  const FetchBooksUseCase(this.repository);
  final BookRepository repository;

  Future<List<BookEntity>> call() => repository.fetchBooks();
}

class FetchBookByIdUseCase {
  const FetchBookByIdUseCase(this.repository);
  final BookRepository repository;

  Future<BookEntity?> call(String id) => repository.fetchBookById(id);
}

class WatchBooksUseCase {
  const WatchBooksUseCase(this.repository);
  final BookRepository repository;

  Stream<List<BookEntity>> call() => repository.watchBooks();
}

class AddBookUseCase {
  const AddBookUseCase(this.repository);
  final BookRepository repository;

  Future<void> call(BookEntity book) => repository.addBook(book);
}

class EditBookUseCase {
  const EditBookUseCase(this.repository);
  final BookRepository repository;

  Future<void> call(BookEntity book) => repository.editBook(book);
}

class RemoveBookUseCase {
  const RemoveBookUseCase(this.repository);
  final BookRepository repository;

  Future<void> call(String id) => repository.removeBook(id);
}
