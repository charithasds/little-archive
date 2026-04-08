import '../entities/author_entity.dart';
import '../repositories/author_repository.dart';

class GetAuthorsUseCase {
  const GetAuthorsUseCase(this.repository);
  final AuthorRepository repository;

  Future<List<AuthorEntity>> call(String userId) => repository.getAuthors(userId);
}

class WatchAuthorsUseCase {
  const WatchAuthorsUseCase(this.repository);
  final AuthorRepository repository;

  Stream<List<AuthorEntity>> call(String userId) => repository.watchAuthors(userId);
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

class UpdateAuthorUseCase {
  const UpdateAuthorUseCase(this.repository);
  final AuthorRepository repository;

  Future<void> call(AuthorEntity author) => repository.updateAuthor(author);
}

class DeleteAuthorUseCase {
  const DeleteAuthorUseCase(this.repository);
  final AuthorRepository repository;

  Future<void> call(String id) => repository.deleteAuthor(id);
}
