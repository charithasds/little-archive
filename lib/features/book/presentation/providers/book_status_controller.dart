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
  bool build() => false;

  Future<void> changeCollectionStatus(
    BookEntity book,
    CollectionStatus status, {
    DateTime? collectedDate,
    String? readerId,
    DateTime? lendedDate,
    DateTime? dueDate,
  }) async {
    state = true;

    try {
      final EditBookUseCase editBook = ref.read(editBookUseCaseProvider);
      BookEntity updated;

      switch (status) {
        case CollectionStatus.announced:
          updated = book.copyWith(collectionStatus: status, lastUpdated: DateTime.now());
        case CollectionStatus.shoppingList:
          updated = book.copyWith(
            collectionStatus: status,
            collectedDate: const Nullable<DateTime?>(null),
            lastUpdated: DateTime.now(),
          );
        case CollectionStatus.onTheWay:
          updated = book.copyWith(collectionStatus: status, lastUpdated: DateTime.now());
        case CollectionStatus.collected:
          updated = book.copyWith(
            collectionStatus: status,
            collectedDate: Nullable<DateTime?>(collectedDate),
            readerId: const Nullable<String?>(null),
            lendedDate: const Nullable<DateTime?>(null),
            dueDate: const Nullable<DateTime?>(null),
            lastUpdated: DateTime.now(),
          );
        case CollectionStatus.lended:
          updated = book.copyWith(
            collectionStatus: status,
            readerId: Nullable<String?>(readerId),
            lendedDate: Nullable<DateTime?>(lendedDate),
            dueDate: Nullable<DateTime?>(dueDate),
            lastUpdated: DateTime.now(),
          );
        case CollectionStatus.outOfPrint:
          updated = book.copyWith(collectionStatus: status, lastUpdated: DateTime.now());
      }

      await editBook(updated, oldBook: book);
    } finally {
      state = false;
    }
  }

  Future<void> changeReadingStatus(
    BookEntity book,
    ReadingStatus status, {
    int? pausedPage,
    DateTime? completedDate,
  }) async {
    state = true;

    try {
      final EditBookUseCase editBook = ref.read(editBookUseCaseProvider);
      BookEntity updated;

      switch (status) {
        case ReadingStatus.notStarted:
          updated = book.copyWith(readingStatus: status, lastUpdated: DateTime.now());
        case ReadingStatus.reading:
          updated = book.copyWith(readingStatus: status, lastUpdated: DateTime.now());
        case ReadingStatus.paused:
          updated = book.copyWith(
            readingStatus: status,
            pausedPage: Nullable<int?>(pausedPage),
            lastUpdated: DateTime.now(),
          );
        case ReadingStatus.completed:
          updated = book.copyWith(
            readingStatus: status,
            pausedPage: const Nullable<int?>(null),
            completedDate: Nullable<DateTime?>(completedDate),
            lastUpdated: DateTime.now(),
          );
        case ReadingStatus.abandoned:
          updated = book.copyWith(
            readingStatus: status,
            pausedPage: const Nullable<int?>(null),
            lastUpdated: DateTime.now(),
          );
      }

      await editBook(updated, oldBook: book);
    } finally {
      state = false;
    }
  }
}
