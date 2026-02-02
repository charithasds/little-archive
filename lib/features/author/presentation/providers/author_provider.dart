import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firestore_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/author_remote_datasource.dart';
import '../../data/repositories/author_repository_impl.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/repositories/author_repository.dart';

final Provider<AuthorRemoteDataSource> authorRemoteDataSourceProvider =
    Provider<AuthorRemoteDataSource>((Ref ref) {
      final FirebaseFirestore firestore = ref.watch(firestoreProvider);
      return AuthorRemoteDataSourceImpl(firestore: firestore);
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
