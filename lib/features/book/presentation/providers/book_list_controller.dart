import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../creator/domain/entities/creator_entity.dart';
import '../../../creator/presentation/providers/creator_provider.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../../reader/domain/entities/reader_entity.dart';
import '../../../reader/presentation/providers/reader_provider.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../work/domain/entities/work_entity.dart';
import '../../../work/presentation/providers/work_provider.dart';
import '../../domain/entities/book_entity.dart';
import 'book_provider.dart';

part 'book_list_controller.g.dart';

class BookListState {
  const BookListState({
    required this.displayedBooks,
    required this.totalFiltered,
    required this.searchQuery,
  });

  final List<BookEntity> displayedBooks;
  final int totalFiltered;
  final String searchQuery;
}

@riverpod
class BookListController extends _$BookListController {
  @override
  BookListState build() {
    final List<BookEntity> allBooks = ref.watch(booksStreamProvider).value ?? <BookEntity>[];

    ref.watch(creatorsStreamProvider);
    ref.watch(creatorsStreamProvider);
    ref.watch(worksStreamProvider);
    ref.watch(publishersStreamProvider);
    ref.watch(readersStreamProvider);
    ref.watch(sequencesStreamProvider);
    ref.watch(allSequenceVolumesStreamProvider);

    return _calculateState(allBooks, '');
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) {
      return;
    }

    final List<BookEntity> allBooks = ref.read(booksStreamProvider).value ?? <BookEntity>[];

    state = _calculateState(allBooks, query);
  }

  BookListState _calculateState(List<BookEntity> allBooks, String query) {
    final List<BookEntity> sortedBooks = List<BookEntity>.from(
      allBooks,
    )..sort((BookEntity a, BookEntity b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    List<BookEntity> filtered = sortedBooks;

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();

      String getAuthorNames(List<String> ids) {
        final List<CreatorEntity> authors =
            ref.read(creatorsStreamProvider).value ?? <CreatorEntity>[];

        return authors
            .where((CreatorEntity a) => ids.contains(a.id))
            .map((CreatorEntity a) => a.name)
            .join(' ')
            .toLowerCase();
      }

      String getTranslatorNames(List<String> ids) {
        final List<CreatorEntity> translators =
            ref.read(creatorsStreamProvider).value ?? <CreatorEntity>[];

        return translators
            .where((CreatorEntity t) => ids.contains(t.id))
            .map((CreatorEntity t) => t.name)
            .join(' ')
            .toLowerCase();
      }

      String getPublisherName(String? id) {
        if (id == null) {
          return '';
        }

        final List<PublisherEntity> pubs =
            ref.read(publishersStreamProvider).value ?? <PublisherEntity>[];
        final PublisherEntity? p = pubs.where((PublisherEntity p) => p.id == id).firstOrNull;

        return p?.name.toLowerCase() ?? '';
      }

      String getReaderName(String? id) {
        if (id == null) {
          return '';
        }

        final List<ReaderEntity> readers =
            ref.read(readersStreamProvider).value ?? <ReaderEntity>[];
        final ReaderEntity? r = readers.where((ReaderEntity r) => r.id == id).firstOrNull;

        return r?.name.toLowerCase() ?? '';
      }

      String getWorkTitles(List<String> ids) {
        if (ids.isEmpty) {
          return '';
        }

        final List<WorkEntity> works = ref.read(worksStreamProvider).value ?? <WorkEntity>[];

        return works
            .where((WorkEntity w) => ids.contains(w.id))
            .map((WorkEntity w) => w.title)
            .join(' ')
            .toLowerCase();
      }

      String getSequenceNames(List<String> volumeIds) {
        if (volumeIds.isEmpty) {
          return '';
        }

        final List<SequenceVolumeEntity> volumes =
            ref.read(allSequenceVolumesStreamProvider).value ?? <SequenceVolumeEntity>[];
        final List<SequenceEntity> sequences =
            ref.read(sequencesStreamProvider).value ?? <SequenceEntity>[];
        final List<String> sequenceIds = volumes
            .where((SequenceVolumeEntity v) => volumeIds.contains(v.id))
            .map((SequenceVolumeEntity v) => v.sequenceId)
            .toList();

        return sequences
            .where((SequenceEntity s) => sequenceIds.contains(s.id))
            .map((SequenceEntity s) => s.name)
            .join(' ')
            .toLowerCase();
      }

      filtered = sortedBooks.where((BookEntity b) {
        final bool matchesTitle = b.title.toLowerCase().contains(q);
        final bool matchesCompilationType = b.compilationType.name.toLowerCase().contains(q);
        final bool matchesLanguage = (b.language?.name ?? '').toLowerCase().contains(q);
        final bool matchesGenre = (b.genre?.name ?? '').toLowerCase().contains(q);
        final bool matchesIsbn = (b.isbn ?? '').toLowerCase().contains(q);
        final bool matchesNoOfPages = (b.noOfPages ?? '').toString().toLowerCase().contains(q);
        final bool matchesOriginalTitle = (b.originalTitle ?? '').toLowerCase().contains(q);
        final bool matchesOriginalLanguage = (b.originalLanguage?.name ?? '')
            .toLowerCase()
            .contains(q);
        final bool matchesCollectionStatus = b.collectionStatus.name.toLowerCase().contains(q);
        final bool matchesReadingStatus = b.readingStatus.name.toLowerCase().contains(q);
        final bool matchesNotes = (b.notes ?? '').toLowerCase().contains(q);

        if (matchesTitle ||
            matchesCompilationType ||
            matchesLanguage ||
            matchesGenre ||
            matchesIsbn ||
            matchesNoOfPages ||
            matchesOriginalTitle ||
            matchesOriginalLanguage ||
            matchesCollectionStatus ||
            matchesReadingStatus ||
            matchesNotes) {
          return true;
        }

        final bool matchesAuthors = getAuthorNames(b.authorIds).contains(q);

        if (matchesAuthors) {
          return true;
        }

        final bool matchesTranslators = getTranslatorNames(b.translatorIds).contains(q);

        if (matchesTranslators) {
          return true;
        }

        final bool matchesWorks = getWorkTitles(b.workIds).contains(q);

        if (matchesWorks) {
          return true;
        }

        final bool matchesSequences = getSequenceNames(b.sequenceVolumeIds).contains(q);

        if (matchesSequences) {
          return true;
        }

        final bool matchesPublisher = getPublisherName(b.publisherId).contains(q);

        if (matchesPublisher) {
          return true;
        }

        final bool matchesReader = getReaderName(b.readerId).contains(q);

        if (matchesReader) {
          return true;
        }

        return false;
      }).toList();
    }

    return BookListState(
      displayedBooks: filtered,
      totalFiltered: filtered.length,
      searchQuery: query,
    );
  }
}
