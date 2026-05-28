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

  int noAuthors = 0;
  int noTranslators = 0;
  int noOriginalTitle = 0;
  int noLanguage = 0;
  int noOriginalLanguage = 0;
  int noGenre = 0;
  int noIsbn = 0;
  int noPages = 0;
  int noSequences = 0;
  int noPublisher = 0;
  int noPublishedDate = 0;
  int noCollectedDate = 0;
  int noPausedPage = 0;
  int noCompletedDate = 0;

  for (final BookEntity b in books) {
    if (b.authorIds.isEmpty) {
      noAuthors++;
    }
    if (b.isTranslation) {
      if (b.translatorIds.isEmpty) {
        noTranslators++;
      }
      if (b.originalTitle == null || b.originalTitle!.trim().isEmpty) {
        noOriginalTitle++;
      }
      if (b.originalLanguage == null) {
        noOriginalLanguage++;
      }
    }
    if (b.language == null) {
      noLanguage++;
    }
    if (b.genre == null) {
      noGenre++;
    }
    if (b.isbn == null || b.isbn!.trim().isEmpty) {
      noIsbn++;
    }
    if (b.noOfPages == null) {
      noPages++;
    }
    if (b.sequenceVolumeIds.isEmpty) {
      noSequences++;
    }
    if (b.publisherId == null) {
      noPublisher++;
    }
    if (b.publishedDate == null) {
      noPublishedDate++;
    }

    final bool isCollected = b.collectionStatus == CollectionStatus.collected ||
        b.collectionStatus == CollectionStatus.lended;
    if (isCollected && b.collectedDate == null) {
      noCollectedDate++;
    }
    if (b.readingStatus == ReadingStatus.reading && b.pausedPage == null) {
      noPausedPage++;
    }
    if (b.readingStatus == ReadingStatus.completed && b.completedDate == null) {
      noCompletedDate++;
    }
  }

  return <({String label, int count})>[
    (label: 'No Authors', count: noAuthors),
    (label: 'No Translators', count: noTranslators),
    (label: 'No Original Title', count: noOriginalTitle),
    (label: 'No Language', count: noLanguage),
    (label: 'No Orig. Language', count: noOriginalLanguage),
    (label: 'No Genre', count: noGenre),
    (label: 'No ISBN', count: noIsbn),
    (label: 'No Pages', count: noPages),
    (label: 'No Sequences', count: noSequences),
    (label: 'No Publisher', count: noPublisher),
    (label: 'No Pub. Date', count: noPublishedDate),
    (label: 'No Collected Date', count: noCollectedDate),
    (label: 'No Paused Page', count: noPausedPage),
    (label: 'No Completed Date', count: noCompletedDate),
  ];
}
