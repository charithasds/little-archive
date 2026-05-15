import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/presentation/providers/firebase_provider.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/usecases/sequence_usecases.dart';
import '../../../work/data/repositories/work_repository_impl.dart';
import '../../../work/domain/entities/work_entity.dart';
import '../../../work/domain/repositories/work_repository.dart';
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
  const UpsertBookUseCase({
    required this.firestore,
    required this.bookRepository,
    required this.syncSequenceVolumesUseCase,
    required this.workRepository,
  });

  final FirebaseFirestore firestore;
  final BookRepository bookRepository;
  final SyncBookSequenceVolumesUseCase syncSequenceVolumesUseCase;
  final WorkRepository workRepository;
  Future<BookEntity> call({
    required BookEntity book,
    required Map<SequenceEntity, String> sequenceEntries,
    required bool isEdit,
    bool applyToWorks = false,
  }) async {
    final WriteBatch batch = firestore.batch();

    final List<String> sequenceVolumeIds = await syncSequenceVolumesUseCase(
      bookId: book.id,
      entries: sequenceEntries,
      isEdit: isEdit,
      batch: batch,
    );

    final BookEntity bookToSave = book.copyWith(sequenceVolumeIds: sequenceVolumeIds);

    if (isEdit) {
      await bookRepository.editBook(bookToSave, batch: batch);
    } else {
      await bookRepository.addBook(bookToSave, batch: batch);
    }

    if (applyToWorks && bookToSave.compilationType == CompilationType.multiple) {
      for (final String workId in bookToSave.workIds) {
        final WorkEntity? work = await workRepository.fetchWorkById(workId);
        if (work != null) {
          final WorkEntity updatedWork = work.copyWith(
            bookId: Nullable<String?>(bookToSave.id),
            isTranslation: bookToSave.isTranslation,
            authorIds: bookToSave.authorIds,
            translatorIds: bookToSave.translatorIds,
            language: Nullable<Language?>(bookToSave.language),
            originalLanguage: Nullable<OriginalLanguage?>(bookToSave.originalLanguage),
          );
          await workRepository.editWork(updatedWork, batch: batch);
        }
      }
    }

    await batch.commit();

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
AddBookUseCase addBookUseCase(Ref ref) => AddBookUseCase(ref.watch(bookRepositoryProvider));

@riverpod
EditBookUseCase editBookUseCase(Ref ref) => EditBookUseCase(ref.watch(bookRepositoryProvider));

@riverpod
RemoveBookUseCase removeBookUseCase(Ref ref) =>
    RemoveBookUseCase(ref.watch(bookRepositoryProvider));

@riverpod
UpsertBookUseCase upsertBookUseCase(Ref ref) => UpsertBookUseCase(
  firestore: ref.watch(firebaseFirestoreProvider),
  bookRepository: ref.watch(bookRepositoryProvider),
  syncSequenceVolumesUseCase: ref.watch(syncBookSequenceVolumesUseCaseProvider),
  workRepository: ref.watch(workRepositoryProvider),
);

@riverpod
ScanBookUseCase scanBookUseCase(Ref ref) => ScanBookUseCase(ref.watch(bookRepositoryProvider));
