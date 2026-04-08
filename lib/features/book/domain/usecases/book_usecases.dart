import '../../../../core/shared/domain/usecases/usecase.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';

class GetBooksUseCase implements UseCase<List<BookEntity>, String> {
  GetBooksUseCase(this.repository);
  final BookRepository repository;

  @override
  Future<List<BookEntity>> call(String params) => repository.getBooks(params);
}

class WatchBooksUseCase implements UseCase<Stream<List<BookEntity>>, String> {
  WatchBooksUseCase(this.repository);
  final BookRepository repository;

  @override
  Future<Stream<List<BookEntity>>> call(String params) async => repository.watchBooks(params);
}

class GetBookByIdUseCase implements UseCase<BookEntity?, String> {
  GetBookByIdUseCase(this.repository);
  final BookRepository repository;

  @override
  Future<BookEntity?> call(String params) => repository.getBookById(params);
}

class AddBookUseCase implements UseCase<void, BookEntity> {
  AddBookUseCase(this.repository);
  final BookRepository repository;

  @override
  Future<void> call(BookEntity params) => repository.addBook(params);
}

class UpdateBookUseCase implements UseCase<void, BookEntity> {
  UpdateBookUseCase(this.repository);
  final BookRepository repository;

  @override
  Future<void> call(BookEntity params) => repository.updateBook(params);
}

class DeleteBookUseCase implements UseCase<void, String> {
  DeleteBookUseCase(this.repository);
  final BookRepository repository;

  @override
  Future<void> call(String params) => repository.deleteBook(params);
}
