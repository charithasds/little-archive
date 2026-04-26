import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/author_repository_impl.dart';
import '../entities/author_entity.dart';
import '../repositories/author_repository.dart';

part 'author_usecases.g.dart';

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

class FetchAuthorCountUseCase {
  const FetchAuthorCountUseCase(this.repository);
  final AuthorRepository repository;

  Future<int> call() => repository.fetchCount();
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

@riverpod
GenerateAuthorIdUseCase generateAuthorIdUseCase(Ref ref) =>
    GenerateAuthorIdUseCase(ref.watch(authorRepositoryProvider));

@riverpod
FetchAuthorsUseCase fetchAuthorsUseCase(Ref ref) =>
    FetchAuthorsUseCase(ref.watch(authorRepositoryProvider));

@riverpod
FetchAuthorByIdUseCase fetchAuthorByIdUseCase(Ref ref) =>
    FetchAuthorByIdUseCase(ref.watch(authorRepositoryProvider));

@riverpod
WatchAuthorsUseCase watchAuthorsUseCase(Ref ref) =>
    WatchAuthorsUseCase(ref.watch(authorRepositoryProvider));

@riverpod
FetchAuthorCountUseCase fetchAuthorCountUseCase(Ref ref) =>
    FetchAuthorCountUseCase(ref.watch(authorRepositoryProvider));

@riverpod
AddAuthorUseCase addAuthorUseCase(Ref ref) => AddAuthorUseCase(ref.watch(authorRepositoryProvider));

@riverpod
EditAuthorUseCase editAuthorUseCase(Ref ref) =>
    EditAuthorUseCase(ref.watch(authorRepositoryProvider));

@riverpod
RemoveAuthorUseCase removeAuthorUseCase(Ref ref) =>
    RemoveAuthorUseCase(ref.watch(authorRepositoryProvider));
