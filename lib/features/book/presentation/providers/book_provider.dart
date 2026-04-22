import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/providers/firestore_service_provider.dart';
import '../../../../core/shared/presentation/providers/relationship_sync_service_provider.dart';
import '../../data/datasources/book_remote_datasource.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/usecases/book_usecases.dart';

part 'book_provider.g.dart';

@riverpod
BookRemoteDataSource _bookRemoteDataSource(Ref ref) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    throw const UnauthorizedException();
  }

  return BookRemoteDataSourceImpl(firestoreService: firestoreService, userId: userId);
}

@riverpod
BookRepository _bookRepository(Ref ref) {
  final BookRemoteDataSource remoteDataSource = ref.watch(_bookRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return BookRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}

@riverpod
GenerateBookIdUseCase generateBookIdUseCase(Ref ref) =>
    GenerateBookIdUseCase(ref.watch(_bookRepositoryProvider));

@riverpod
FetchBooksUseCase fetchBooksUseCase(Ref ref) =>
    FetchBooksUseCase(ref.watch(_bookRepositoryProvider));

@riverpod
FetchBookByIdUseCase fetchBookByIdUseCase(Ref ref) =>
    FetchBookByIdUseCase(ref.watch(_bookRepositoryProvider));

@riverpod
WatchBooksUseCase watchBooksUseCase(Ref ref) =>
    WatchBooksUseCase(ref.watch(_bookRepositoryProvider));

@riverpod
AddBookUseCase addBookUseCase(Ref ref) => AddBookUseCase(ref.watch(_bookRepositoryProvider));

@riverpod
EditBookUseCase editBookUseCase(Ref ref) => EditBookUseCase(ref.watch(_bookRepositoryProvider));

@riverpod
RemoveBookUseCase removeBookUseCase(Ref ref) =>
    RemoveBookUseCase(ref.watch(_bookRepositoryProvider));

@riverpod
Stream<List<BookEntity>> booksStream(Ref ref) {
  final WatchBooksUseCase watchBooks = ref.watch(watchBooksUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<BookEntity>>.value(<BookEntity>[]);
  }

  return watchBooks();
}
