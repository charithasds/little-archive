import '../entities/author_entity.dart';
import '../repositories/author_repository.dart';

class GenerateAuthorIdUseCase {
  const GenerateAuthorIdUseCase(this.repository);
  final AuthorRepository repository;

  String call() => repository.generateId();
}

class FetchAuthorsUseCase {
  const FetchAuthorsUseCase(this.repository);
  final AuthorRepository repository;

  Future<List<AuthorEntity>> call() => repository.fetchAuthors();
}

class FetchAuthorByIdUseCase {
  const FetchAuthorByIdUseCase(this.repository);
  final AuthorRepository repository;

  Future<AuthorEntity?> call(String id) => repository.fetchAuthorById(id);
}

class WatchAuthorsUseCase {
  const WatchAuthorsUseCase(this.repository);
  final AuthorRepository repository;

  Stream<List<AuthorEntity>> call() => repository.watchAuthors();
}

class AddAuthorUseCase {
  const AddAuthorUseCase(this.repository);
  final AuthorRepository repository;

  Future<void> call(AuthorEntity author) => repository.addAuthor(author);
}

class EditAuthorUseCase {
  const EditAuthorUseCase(this.repository);
  final AuthorRepository repository;

  Future<void> call(AuthorEntity author) => repository.editAuthor(author);
}

class RemoveAuthorUseCase {
  const RemoveAuthorUseCase(this.repository);
  final AuthorRepository repository;

  Future<void> call(String id) => repository.removeAuthor(id);
}
