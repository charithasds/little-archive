import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/providers/firestore_service_provider.dart';
import '../../../../core/shared/presentation/providers/relationship_sync_service_provider.dart';
import '../../data/datasources/author_remote_datasource.dart';
import '../../data/repositories/author_repository_impl.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/repositories/author_repository.dart';
import '../../domain/usecases/author_usecases.dart';

part 'author_provider.g.dart';

@riverpod
AuthorRemoteDataSource _authorRemoteDataSource(Ref ref) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    throw const UnauthorizedException();
  }

  return AuthorRemoteDataSourceImpl(firestoreService: firestoreService, userId: userId);
}

@riverpod
AuthorRepository _authorRepository(Ref ref) {
  final AuthorRemoteDataSource remoteDataSource = ref.watch(_authorRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return AuthorRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}

@riverpod
GenerateAuthorIdUseCase generateAuthorIdUseCase(Ref ref) =>
    GenerateAuthorIdUseCase(ref.watch(_authorRepositoryProvider));

@riverpod
FetchAuthorsUseCase fetchAuthorsUseCase(Ref ref) =>
    FetchAuthorsUseCase(ref.watch(_authorRepositoryProvider));

@riverpod
FetchAuthorByIdUseCase fetchAuthorByIdUseCase(Ref ref) =>
    FetchAuthorByIdUseCase(ref.watch(_authorRepositoryProvider));

@riverpod
WatchAuthorsUseCase watchAuthorsUseCase(Ref ref) =>
    WatchAuthorsUseCase(ref.watch(_authorRepositoryProvider));

@riverpod
AddAuthorUseCase addAuthorUseCase(Ref ref) => AddAuthorUseCase(ref.watch(_authorRepositoryProvider));

@riverpod
EditAuthorUseCase editAuthorUseCase(Ref ref) =>
    EditAuthorUseCase(ref.watch(_authorRepositoryProvider));

@riverpod
RemoveAuthorUseCase removeAuthorUseCase(Ref ref) =>
    RemoveAuthorUseCase(ref.watch(_authorRepositoryProvider));

@riverpod
Stream<List<AuthorEntity>> authorsStream(Ref ref) {
  final WatchAuthorsUseCase watchAuthors = ref.watch(watchAuthorsUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<AuthorEntity>>.value(<AuthorEntity>[]);
  }

  return watchAuthors();
}
