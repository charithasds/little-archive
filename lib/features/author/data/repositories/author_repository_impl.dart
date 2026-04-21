import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/repositories/author_repository.dart';
import '../datasources/author_remote_datasource.dart';
import '../models/author_model.dart';

class AuthorRepositoryImpl implements AuthorRepository {
  AuthorRepositoryImpl({required this.remoteDataSource, required this.relationshipSyncService});
  final AuthorRemoteDataSource remoteDataSource;
  final RelationshipSyncService relationshipSyncService;

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<AuthorEntity>> getAuthors() => remoteDataSource.fetchAuthors();

  @override
  Future<AuthorEntity?> getAuthorById(String id) => remoteDataSource.fetchAuthorById(id);

  @override
  Stream<List<AuthorEntity>> watchAuthors() => remoteDataSource.watchAuthors();

  @override
  Future<void> addAuthor(AuthorEntity author) => remoteDataSource.addAuthor(
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

  @override
  Future<void> editAuthor(AuthorEntity author) => remoteDataSource.editAuthor(
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

  @override
  Future<void> removeAuthor(String id) async {
    final AuthorModel? existingAuthor = await remoteDataSource.fetchAuthorById(id);

    if (existingAuthor != null) {
      await relationshipSyncService.removeAuthorRelationships(
        authorId: id,
        bookIds: existingAuthor.bookIds,
        workIds: existingAuthor.workIds,
      );
    }

    await remoteDataSource.removeAuthor(id);
  }
}
