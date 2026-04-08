import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/presentation/providers/firestore_service_provider.dart';
import '../../../../core/shared/presentation/providers/relationship_sync_service_provider.dart';
import '../../data/datasources/book_remote_datasource.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/usecases/book_usecases.dart';

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

final Provider<GetBooksUseCase> getBooksUseCaseProvider = Provider<GetBooksUseCase>(
  (Ref ref) => GetBooksUseCase(ref.watch(bookRepositoryProvider)),
);

final Provider<WatchBooksUseCase> watchBooksUseCaseProvider = Provider<WatchBooksUseCase>(
  (Ref ref) => WatchBooksUseCase(ref.watch(bookRepositoryProvider)),
);

final Provider<GetBookByIdUseCase> getBookByIdUseCaseProvider = Provider<GetBookByIdUseCase>(
  (Ref ref) => GetBookByIdUseCase(ref.watch(bookRepositoryProvider)),
);

final Provider<AddBookUseCase> addBookUseCaseProvider = Provider<AddBookUseCase>(
  (Ref ref) => AddBookUseCase(ref.watch(bookRepositoryProvider)),
);

final Provider<UpdateBookUseCase> updateBookUseCaseProvider = Provider<UpdateBookUseCase>(
  (Ref ref) => UpdateBookUseCase(ref.watch(bookRepositoryProvider)),
);

final Provider<DeleteBookUseCase> deleteBookUseCaseProvider = Provider<DeleteBookUseCase>(
  (Ref ref) => DeleteBookUseCase(ref.watch(bookRepositoryProvider)),
);

final StreamProvider<List<BookEntity>> booksStreamProvider = StreamProvider<List<BookEntity>>((
  Ref ref,
) async* {
  final UserEntity? user = ref.watch(authStateProvider).value;
  if (user == null) {
    yield <BookEntity>[];
  } else {
    final WatchBooksUseCase watchBooks = ref.watch(watchBooksUseCaseProvider);
    yield* await watchBooks(user.uid);
  }
});
