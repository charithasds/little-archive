import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/presentation/providers/firestore_service_provider.dart';
import '../../../../core/shared/presentation/providers/relationship_sync_service_provider.dart';
import '../../data/datasources/author_remote_datasource.dart';
import '../../data/repositories/author_repository_impl.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/repositories/author_repository.dart';
import '../../domain/usecases/author_usecases.dart';

part 'author_provider.g.dart';

@riverpod
AuthorRemoteDataSource authorRemoteDataSource(Ref ref) {
      final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
      return AuthorRemoteDataSourceImpl(firestoreService: firestoreService);
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

@riverpod
GetAuthorsUseCase getAuthorsUseCase(Ref ref) => GetAuthorsUseCase(ref.watch(authorRepositoryProvider));

@riverpod
WatchAuthorsUseCase watchAuthorsUseCase(Ref ref) => WatchAuthorsUseCase(ref.watch(authorRepositoryProvider));

@riverpod
GetAuthorByIdUseCase getAuthorByIdUseCase(Ref ref) => GetAuthorByIdUseCase(ref.watch(authorRepositoryProvider));

@riverpod
AddAuthorUseCase addAuthorUseCase(Ref ref) => AddAuthorUseCase(ref.watch(authorRepositoryProvider));

@riverpod
UpdateAuthorUseCase updateAuthorUseCase(Ref ref) => UpdateAuthorUseCase(ref.watch(authorRepositoryProvider));

@riverpod
DeleteAuthorUseCase deleteAuthorUseCase(Ref ref) => DeleteAuthorUseCase(ref.watch(authorRepositoryProvider));

@riverpod
Stream<List<AuthorEntity>> authorsStream(Ref ref) {
    final WatchAuthorsUseCase watchAuthors = ref.watch(watchAuthorsUseCaseProvider);
    final UserEntity? user = ref.watch(authStateProvider).value;
    if (user == null) {
      return Stream<List<AuthorEntity>>.value(<AuthorEntity>[]);
    }
    return watchAuthors(user.uid);
  }
