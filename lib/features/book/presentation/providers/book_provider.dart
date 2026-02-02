import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firestore_provider.dart';
import '../../../../core/services/relationship_sync_service.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/book_remote_datasource.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';

final Provider<BookRemoteDataSource> bookRemoteDataSourceProvider = Provider<BookRemoteDataSource>((
  Ref ref,
) {
  final FirebaseFirestore firestore = ref.watch(firestoreProvider);
  return BookRemoteDataSourceImpl(firestore: firestore);
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
