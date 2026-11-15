import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repositories/book_repository_impl.dart';
import '../domain/usecases/book_usecases.dart';

export '../domain/usecases/book_usecases.dart';

part 'book_usecase_providers.g.dart';

@riverpod
GenerateBookIdUseCase generateBookIdUseCase(Ref ref) =>
    GenerateBookIdUseCase(ref.watch(bookRepositoryProvider));

@riverpod
FetchBooksUseCase fetchBooksUseCase(Ref ref) =>
    FetchBooksUseCase(ref.watch(bookRepositoryProvider));

@riverpod
FetchBookByIdUseCase fetchBookByIdUseCase(Ref ref) =>
    FetchBookByIdUseCase(ref.watch(bookRepositoryProvider));

@riverpod
WatchBooksUseCase watchBooksUseCase(Ref ref) =>
    WatchBooksUseCase(ref.watch(bookRepositoryProvider));

@riverpod
AddBookUseCase addBookUseCase(Ref ref) => AddBookUseCase(ref.watch(bookRepositoryProvider));

@riverpod
EditBookUseCase editBookUseCase(Ref ref) => EditBookUseCase(ref.watch(bookRepositoryProvider));

@riverpod
RemoveBookUseCase removeBookUseCase(Ref ref) =>
    RemoveBookUseCase(ref.watch(bookRepositoryProvider));

@riverpod
UpsertBookUseCase upsertBookUseCase(Ref ref) =>
    UpsertBookUseCase(ref.watch(bookRepositoryProvider));

@riverpod
ScanBookUseCase scanBookUseCase(Ref ref) => ScanBookUseCase(ref.watch(bookRepositoryProvider));
