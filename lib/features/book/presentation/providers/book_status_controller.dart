import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/book_usecases.dart';

part 'book_status_controller.g.dart';

@riverpod
class BookStatusController extends _$BookStatusController {
  @override
  bool build() => false; // isLoading

  /// Moves a book to the given [CollectionStatus].
  /// For [CollectionStatus.lended] use [lendBook] to include reader + dates.
  Future<void> setCollectionStatus(
    BookEntity book,
    CollectionStatus status, {
    DateTime? collectedDate,
  }) async {
    state = true;
    try {
      final EditBookUseCase editBook = ref.read(editBookUseCaseProvider);
      final BookEntity updated = book.copyWith(
        collectionStatus: status,
        // Set collectedDate when moving to collected
        collectedDate: status == CollectionStatus.collected
            ? Nullable<DateTime?>(collectedDate ?? book.collectedDate ?? DateTime.now())
            : const Nullable<DateTime?>(null),
        // Clear lend info when not lended
        lendedDate: status != CollectionStatus.lended ? const Nullable<DateTime?>(null) : null,
        dueDate: status != CollectionStatus.lended ? const Nullable<DateTime?>(null) : null,
        readerId: status != CollectionStatus.lended ? const Nullable<String?>(null) : null,
        lastUpdated: DateTime.now(),
      );
      await editBook(updated);
    } finally {
      state = false;
    }
  }

  /// Lends a book to a reader.
  Future<void> lendBook(
    BookEntity book, {
    required String readerId,
    required DateTime lendedDate,
    required DateTime dueDate,
  }) async {
    state = true;
    try {
      final EditBookUseCase editBook = ref.read(editBookUseCaseProvider);
      final BookEntity updated = book.copyWith(
        collectionStatus: CollectionStatus.lended,
        lendedDate: Nullable<DateTime?>(lendedDate),
        dueDate: Nullable<DateTime?>(dueDate),
        readerId: Nullable<String?>(readerId),
        collectedDate: Nullable<DateTime?>(book.collectedDate ?? DateTime.now()),
        lastUpdated: DateTime.now(),
      );
      await editBook(updated);
    } finally {
      state = false;
    }
  }

  /// Sets the reading status of a book.
  Future<void> setReadingStatus(BookEntity book, ReadingStatus status) async {
    state = true;
    try {
      final EditBookUseCase editBook = ref.read(editBookUseCaseProvider);
      final BookEntity updated = book.copyWith(
        readingStatus: status,
        completedDate: status == ReadingStatus.completed
            ? Nullable<DateTime?>(book.completedDate ?? DateTime.now())
            : null,
        lastUpdated: DateTime.now(),
      );
      await editBook(updated);
    } finally {
      state = false;
    }
  }
}
