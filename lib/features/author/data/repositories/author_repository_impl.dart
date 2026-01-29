import '../datasources/author_remote_datasource.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/repositories/author_repository.dart';
import '../models/author_model.dart';

class AuthorRepositoryImpl implements AuthorRepository {
  final AuthorRemoteDataSource remoteDataSource;

  AuthorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AuthorEntity>> getAuthors(String userId) =>
      remoteDataSource.getAuthors(userId);

  @override
  Future<AuthorEntity?> getAuthorById(String id) =>
      remoteDataSource.getAuthorById(id);

  @override
  Future<void> addAuthor(AuthorEntity author) {
    return remoteDataSource.addAuthor(
      AuthorModel(
        id: author.id,
        userId: author.userId,
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
  Future<void> updateAuthor(AuthorEntity author) {
    return remoteDataSource.updateAuthor(
      AuthorModel(
        id: author.id,
        userId: author.userId,
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
  Future<void> deleteAuthor(String id) => remoteDataSource.deleteAuthor(id);

  @override
  Stream<List<AuthorEntity>> watchAuthors(String userId) =>
      remoteDataSource.watchAuthors(userId);
}
