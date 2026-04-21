import '../entities/author_entity.dart';
import '../repositories/author_repository.dart';

class GetAuthorsUseCase {
  const GetAuthorsUseCase(this.repository);
  final AuthorRepository repository;

  Future<List<AuthorEntity>> call() => repository.getAuthors();
}

class WatchAuthorsUseCase {
  const WatchAuthorsUseCase(this.repository);
  final AuthorRepository repository;

  Stream<List<AuthorEntity>> call() => repository.watchAuthors();
}

class GetAuthorByIdUseCase {
  const GetAuthorByIdUseCase(this.repository);
  final AuthorRepository repository;

  Future<AuthorEntity?> call(String id) => repository.getAuthorById(id);
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
