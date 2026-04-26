import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/repositories/author_repository.dart';
import '../datasources/author_remote_datasource.dart';
import '../models/author_model.dart';

part 'author_repository_impl.g.dart';

class AuthorRepositoryImpl implements AuthorRepository {
  AuthorRepositoryImpl({required this.remoteDataSource, required this.relationshipSyncService});

  final AuthorRemoteDataSource remoteDataSource;
  final RelationshipSyncService relationshipSyncService;

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

    await relationshipSyncService.syncAuthorRelationships(
      authorId: author.id,
      newBookIds: author.bookIds,
      newWorkIds: author.workIds,
    );
  }

  @override
  Future<void> editAuthor(AuthorEntity author) async {
    final AuthorModel? existingAuthor = await remoteDataSource.fetchAuthorById(author.id);

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

    await relationshipSyncService.syncAuthorRelationships(
      authorId: author.id,
      newBookIds: author.bookIds,
      newWorkIds: author.workIds,
      oldBookIds: existingAuthor?.bookIds ?? <String>[],
      oldWorkIds: existingAuthor?.workIds ?? <String>[],
    );
  }

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

  @override
  Future<int> fetchCount() => remoteDataSource.fetchCount();
}

@riverpod
AuthorRepository authorRepository(Ref ref) {
  final AuthorRemoteDataSource remoteDataSource = ref.watch(authorRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return AuthorRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}
