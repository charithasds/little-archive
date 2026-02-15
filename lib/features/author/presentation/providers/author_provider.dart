import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/presentation/providers/firestore_provider.dart';
import '../../data/datasources/author_remote_datasource.dart';
import '../../data/repositories/author_repository_impl.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/repositories/author_repository.dart';

final Provider<AuthorRemoteDataSource> authorRemoteDataSourceProvider =
    Provider<AuthorRemoteDataSource>((Ref ref) {
      final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
      return AuthorRemoteDataSourceImpl(firestoreService: firestoreService);
    });

final Provider<AuthorRepository> authorRepositoryProvider = Provider<AuthorRepository>((Ref ref) {
  final AuthorRemoteDataSource remoteDataSource = ref.watch(authorRemoteDataSourceProvider);
  return AuthorRepositoryImpl(remoteDataSource: remoteDataSource);
});

final StreamProvider<List<AuthorEntity>> authorsStreamProvider = StreamProvider<List<AuthorEntity>>(
  (Ref ref) {
    final AuthorRepository repository = ref.watch(authorRepositoryProvider);
    final UserEntity? user = ref.watch(authStateProvider).value;
    if (user == null) {
      return Stream<List<AuthorEntity>>.value(<AuthorEntity>[]);
    }
    return repository.watchAuthors(user.uid);
  },
);
