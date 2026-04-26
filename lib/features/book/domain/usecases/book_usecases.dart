import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/usecases/sequence_usecases.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../entities/book_entity.dart';
import '../entities/scanned_book_entity.dart';
import '../repositories/book_repository.dart';

part 'book_usecases.g.dart';

class GenerateBookIdUseCase {
  const GenerateBookIdUseCase(this.repository);
  final BookRepository repository;

  String call() => repository.generateId();
}

class FetchBooksUseCase {
  const FetchBooksUseCase(this.repository);
  final BookRepository repository;

  Future<List<BookEntity>> call() => repository.fetchBooks();
}

class FetchBookByIdUseCase {
  const FetchBookByIdUseCase(this.repository);
  final BookRepository repository;

  Future<BookEntity?> call(String id) => repository.fetchBookById(id);
}

class WatchBooksUseCase {
  const WatchBooksUseCase(this.repository);
  final BookRepository repository;

  Stream<List<BookEntity>> call() => repository.watchBooks();
}

class FetchBookCountUseCase {
  const FetchBookCountUseCase(this.repository);
  final BookRepository repository;

  Future<int> call() => repository.fetchCount();
}

class AddBookUseCase {
  const AddBookUseCase(this.repository);
  final BookRepository repository;

  Future<void> call(BookEntity book) => repository.addBook(book);
}

class EditBookUseCase {
  const EditBookUseCase(this.repository);
  final BookRepository repository;

  Future<void> call(BookEntity book) => repository.editBook(book);
}

class RemoveBookUseCase {
  const RemoveBookUseCase(this.repository);
  final BookRepository repository;

  Future<void> call(String id) => repository.removeBook(id);
}

class UpsertBookUseCase {
  const UpsertBookUseCase({required this.bookRepository, required this.syncSequenceVolumesUseCase});

  final BookRepository bookRepository;
  final SyncBookSequenceVolumesUseCase syncSequenceVolumesUseCase;

  Future<BookEntity> call({
    required BookEntity book,
    required Map<SequenceEntity, String> sequenceEntries,
    required bool isEdit,
  }) async {
    final List<String> sequenceVolumeIds = await syncSequenceVolumesUseCase(
      bookId: book.id,
      entries: sequenceEntries,
      isEdit: isEdit,
    );

    final BookEntity bookToSave = book.copyWith(sequenceVolumeIds: sequenceVolumeIds);

    if (isEdit) {
      await bookRepository.editBook(bookToSave);
    } else {
      await bookRepository.addBook(bookToSave);
    }

    return bookToSave;
  }
}

class ScanBookUseCase {
  const ScanBookUseCase(this.repository);
  final BookRepository repository;

  Future<ScannedBookEntity> call(Uint8List imageBytes) => repository.scanBookCover(imageBytes);
}

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
FetchBookCountUseCase fetchBookCountUseCase(Ref ref) =>
    FetchBookCountUseCase(ref.watch(bookRepositoryProvider));

@riverpod
AddBookUseCase addBookUseCase(Ref ref) => AddBookUseCase(ref.watch(bookRepositoryProvider));

@riverpod
EditBookUseCase editBookUseCase(Ref ref) => EditBookUseCase(ref.watch(bookRepositoryProvider));

@riverpod
RemoveBookUseCase removeBookUseCase(Ref ref) =>
    RemoveBookUseCase(ref.watch(bookRepositoryProvider));

@riverpod
UpsertBookUseCase upsertBookUseCase(Ref ref) => UpsertBookUseCase(
  bookRepository: ref.watch(bookRepositoryProvider),
  syncSequenceVolumesUseCase: ref.watch(syncBookSequenceVolumesUseCaseProvider),
);

@riverpod
ScanBookUseCase scanBookUseCase(Ref ref) => ScanBookUseCase(ref.watch(bookRepositoryProvider));
