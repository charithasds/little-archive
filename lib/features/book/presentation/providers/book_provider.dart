import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

part 'book_provider.g.dart';

final Provider<BookRemoteDataSource> bookRemoteDataSourceProvider = Provider<BookRemoteDataSource>((
  Ref ref,
) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  return BookRemoteDataSourceImpl(firestoreService: firestoreService);
});

@riverpod
BookRepository bookRepository(Ref ref) {
  final BookRemoteDataSource remoteDataSource = ref.watch(bookRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );
  return BookRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}

@riverpod
GetBooksUseCase getBooksUseCase(Ref ref) => GetBooksUseCase(ref.watch(bookRepositoryProvider));

@riverpod
WatchBooksUseCase watchBooksUseCase(Ref ref) => WatchBooksUseCase(ref.watch(bookRepositoryProvider));

@riverpod
GetBookByIdUseCase getBookByIdUseCase(Ref ref) => GetBookByIdUseCase(ref.watch(bookRepositoryProvider));

@riverpod
AddBookUseCase addBookUseCase(Ref ref) => AddBookUseCase(ref.watch(bookRepositoryProvider));

@riverpod
UpdateBookUseCase updateBookUseCase(Ref ref) => UpdateBookUseCase(ref.watch(bookRepositoryProvider));

@riverpod
DeleteBookUseCase deleteBookUseCase(Ref ref) => DeleteBookUseCase(ref.watch(bookRepositoryProvider));

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
