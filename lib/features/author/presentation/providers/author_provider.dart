import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final Provider<AuthorRemoteDataSource> authorRemoteDataSourceProvider =
    Provider<AuthorRemoteDataSource>((Ref ref) {
      final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
      return AuthorRemoteDataSourceImpl(firestoreService: firestoreService);
    });

final Provider<AuthorRepository> authorRepositoryProvider = Provider<AuthorRepository>((Ref ref) {
  final AuthorRemoteDataSource remoteDataSource = ref.watch(authorRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );
  return AuthorRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
});

final Provider<GetAuthorsUseCase> getAuthorsUseCaseProvider = Provider<GetAuthorsUseCase>(
  (Ref ref) => GetAuthorsUseCase(ref.watch(authorRepositoryProvider)),
);

final Provider<WatchAuthorsUseCase> watchAuthorsUseCaseProvider = Provider<WatchAuthorsUseCase>(
  (Ref ref) => WatchAuthorsUseCase(ref.watch(authorRepositoryProvider)),
);

final Provider<GetAuthorByIdUseCase> getAuthorByIdUseCaseProvider = Provider<GetAuthorByIdUseCase>(
  (Ref ref) => GetAuthorByIdUseCase(ref.watch(authorRepositoryProvider)),
);

final Provider<AddAuthorUseCase> addAuthorUseCaseProvider = Provider<AddAuthorUseCase>(
  (Ref ref) => AddAuthorUseCase(ref.watch(authorRepositoryProvider)),
);

final Provider<UpdateAuthorUseCase> updateAuthorUseCaseProvider = Provider<UpdateAuthorUseCase>(
  (Ref ref) => UpdateAuthorUseCase(ref.watch(authorRepositoryProvider)),
);

final Provider<DeleteAuthorUseCase> deleteAuthorUseCaseProvider = Provider<DeleteAuthorUseCase>(
  (Ref ref) => DeleteAuthorUseCase(ref.watch(authorRepositoryProvider)),
);

final StreamProvider<List<AuthorEntity>> authorsStreamProvider = StreamProvider<List<AuthorEntity>>(
  (Ref ref) {
    final WatchAuthorsUseCase watchAuthors = ref.watch(watchAuthorsUseCaseProvider);
    final UserEntity? user = ref.watch(authStateProvider).value;
    if (user == null) {
      return Stream<List<AuthorEntity>>.value(<AuthorEntity>[]);
    }
    return watchAuthors(user.uid);
  },
);
