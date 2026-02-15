import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/presentation/providers/firestore_provider.dart';
import '../../data/datasources/book_remote_datasource.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';

final Provider<BookRemoteDataSource> bookRemoteDataSourceProvider = Provider<BookRemoteDataSource>((
  Ref ref,
) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  return BookRemoteDataSourceImpl(firestoreService: firestoreService);
});

final Provider<BookRepository> bookRepositoryProvider = Provider<BookRepository>((Ref ref) {
  final BookRemoteDataSource remoteDataSource = ref.watch(bookRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );
  return BookRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
});

final StreamProvider<List<BookEntity>> booksStreamProvider = StreamProvider<List<BookEntity>>((
  Ref ref,
) {
  final BookRepository repository = ref.watch(bookRepositoryProvider);
  final UserEntity? user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream<List<BookEntity>>.value(<BookEntity>[]);
  }
  return repository.watchBooks(user.uid);
});
