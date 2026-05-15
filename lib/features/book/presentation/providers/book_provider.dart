import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/book_usecases.dart';

part 'book_provider.g.dart';

@riverpod
Stream<List<BookEntity>> booksStream(Ref ref) {
  final WatchBooksUseCase watchBooks = ref.watch(watchBooksUseCaseProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    return Stream<List<BookEntity>>.value(<BookEntity>[]);
  }

  return watchBooks();
}

@riverpod
int? bookCount(Ref ref) => ref.watch(booksStreamProvider).value?.length;

@riverpod
Future<BookEntity?> book(Ref ref, String id) async {
  final List<BookEntity> books = await ref.watch(booksStreamProvider.future);

  try {
    return books.firstWhere((BookEntity b) => b.id == id);
  } catch (_) {
    return null;
  }
}

// ── Book statistics providers ──────────────────────────────────────────────

@riverpod
Map<CollectionStatus, int>? booksByCollectionStatus(Ref ref) {
  final List<BookEntity>? books = ref.watch(booksStreamProvider).value;
  if (books == null) {
    return null;
  }
  final Map<CollectionStatus, int> result = <CollectionStatus, int>{};
  for (final CollectionStatus s in CollectionStatus.values) {
    result[s] = books.where((BookEntity b) => b.collectionStatus == s).length;
  }
  return result;
}

@riverpod
Map<ReadingStatus, int>? booksByReadingStatus(Ref ref) {
  final List<BookEntity>? books = ref.watch(booksStreamProvider).value;
  if (books == null) {
    return null;
  }
  final Map<ReadingStatus, int> result = <ReadingStatus, int>{};
  for (final ReadingStatus s in ReadingStatus.values) {
    result[s] = books.where((BookEntity b) => b.readingStatus == s).length;
  }
  return result;
}

@riverpod
int? booksLendedCount(Ref ref) {
  final List<BookEntity>? books = ref.watch(booksStreamProvider).value;
  return books?.where((BookEntity b) => b.lendedDate != null).length;
}

// ── Book missing-info provider ─────────────────────────────────────────────
//
// Each item is a (label, count) record. The count is the number of books
// for which the corresponding field is missing, using conditional logic:
//   - isTranslation-gated fields are only checked for translated books.
//   - Status-gated fields are only checked for books in the relevant status.

@riverpod
List<({String label, int count})>? booksMissingInfo(Ref ref) {
  final List<BookEntity>? books = ref.watch(booksStreamProvider).value;
  if (books == null) {
    return null;
  }

  int countWhere(bool Function(BookEntity) test) => books.where(test).length;

  final List<BookEntity> translations = books.where((BookEntity b) => b.isTranslation).toList();

  final List<BookEntity> collected = books
      .where(
        (BookEntity b) =>
            b.collectionStatus == CollectionStatus.collected ||
            b.collectionStatus == CollectionStatus.lended,
      )
      .toList();

  final List<BookEntity> reading = books
      .where((BookEntity b) => b.readingStatus == ReadingStatus.reading)
      .toList();

  final List<BookEntity> completed = books
      .where((BookEntity b) => b.readingStatus == ReadingStatus.completed)
      .toList();

  return <({String label, int count})>[
    (label: 'No Authors', count: countWhere((BookEntity b) => b.authorIds.isEmpty)),
    (
      label: 'No Translators',
      count: translations.where((BookEntity b) => b.translatorIds.isEmpty).length,
    ),
    (
      label: 'No Original Title',
      count: translations
          .where((BookEntity b) => b.originalTitle == null || b.originalTitle!.trim().isEmpty)
          .length,
    ),
    (label: 'No Language', count: countWhere((BookEntity b) => b.language == null)),
    (
      label: 'No Orig. Language',
      count: translations.where((BookEntity b) => b.originalLanguage == null).length,
    ),
    (label: 'No Genre', count: countWhere((BookEntity b) => b.genre == null)),
    (
      label: 'No ISBN',
      count: countWhere((BookEntity b) => b.isbn == null || b.isbn!.trim().isEmpty),
    ),
    (label: 'No Pages', count: countWhere((BookEntity b) => b.noOfPages == null)),
    (label: 'No Sequences', count: countWhere((BookEntity b) => b.sequenceVolumeIds.isEmpty)),
    (label: 'No Publisher', count: countWhere((BookEntity b) => b.publisherId == null)),
    (label: 'No Pub. Date', count: countWhere((BookEntity b) => b.publishedDate == null)),
    (
      label: 'No Collected Date',
      count: collected.where((BookEntity b) => b.collectedDate == null).length,
    ),
    (label: 'No Paused Page', count: reading.where((BookEntity b) => b.pausedPage == null).length),
    (
      label: 'No Completed Date',
      count: completed.where((BookEntity b) => b.completedDate == null).length,
    ),
  ];
}
