import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

class GetBooksUseCase {
  const GetBooksUseCase(this.repository);
  final BookRepository repository;

  Future<List<BookEntity>> call() => repository.getBooks();
}

class WatchBooksUseCase {
  const WatchBooksUseCase(this.repository);
  final BookRepository repository;

  Stream<List<BookEntity>> call() => repository.watchBooks();
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
