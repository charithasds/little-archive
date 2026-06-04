import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/author_entity.dart';
import '../../domain/repositories/author_repository.dart';
import '../datasources/author_remote_datasource.dart';
import '../models/author_model.dart';

part 'author_repository_impl.g.dart';

class AuthorRepositoryImpl implements AuthorRepository {
  AuthorRepositoryImpl({required this.remoteDataSource});

  final AuthorRemoteDataSource remoteDataSource;

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<AuthorEntity>> fetchAuthors() => remoteDataSource.fetchAuthors();

  @override
  Future<AuthorEntity?> fetchAuthorById(String id) => remoteDataSource.fetchAuthorById(id);

  @override
  Stream<List<AuthorEntity>> watchAuthors() => remoteDataSource.watchAuthors();

  @override
  Future<void> addAuthor(AuthorEntity author) async {
    await remoteDataSource.addAuthor(
      AuthorModel(
        id: author.id,
        name: author.name,
        image: author.image,
        otherName: author.otherName,
        website: author.website,
        facebook: author.facebook,
        bookIds: author.bookIds,
        workIds: author.workIds,
        createdDate: author.createdDate,
        lastUpdated: author.lastUpdated,
      ),
    );
  }

  @override
  Future<void> editAuthor(AuthorEntity author, {AuthorEntity? oldAuthor}) async {
    await remoteDataSource.editAuthor(
      AuthorModel(
        id: author.id,
        name: author.name,
        image: author.image,
        otherName: author.otherName,
        website: author.website,
        facebook: author.facebook,
        bookIds: author.bookIds,
        workIds: author.workIds,
        createdDate: author.createdDate,
        lastUpdated: author.lastUpdated,
      ),
    );
  }

  @override
  Future<void> removeAuthor(String id) async {
    await remoteDataSource.removeAuthor(id);
  }
}

@riverpod
AuthorRepository authorRepository(Ref ref) {
  final AuthorRemoteDataSource remoteDataSource = ref.watch(authorRemoteDataSourceProvider);

  return AuthorRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
}
