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
import 'book_usecase_providers.dart';

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

  Future<void> removeBook(String id) => ref.read(removeBookUseCaseProvider)(id);

  BookListState _calculateState(List<BookEntity> allBooks, String query) {
    final List<BookEntity> sortedBooks = List<BookEntity>.from(
      allBooks,
    )..sort((BookEntity a, BookEntity b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    List<BookEntity> filtered = sortedBooks;

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();

      final List<CreatorEntity> creators =
          ref.read(creatorsStreamProvider).value ?? <CreatorEntity>[];
      final List<PublisherEntity> pubs =
          ref.read(publishersStreamProvider).value ?? <PublisherEntity>[];
      final List<ReaderEntity> readers =
          ref.read(readersStreamProvider).value ?? <ReaderEntity>[];
      final List<WorkEntity> works = ref.read(worksStreamProvider).value ?? <WorkEntity>[];
      final List<SequenceVolumeEntity> volumes =
          ref.read(allSequenceVolumesStreamProvider).value ?? <SequenceVolumeEntity>[];
      final List<SequenceEntity> sequences =
          ref.read(sequencesStreamProvider).value ?? <SequenceEntity>[];

      bool matchesCreatorIds(List<String> ids) {
        if (ids.isEmpty) {
          return false;
        }
        return creators.any(
          (CreatorEntity c) =>
              ids.contains(c.id) &&
              (c.name.toLowerCase().contains(q) ||
                  (c.otherName ?? '').toLowerCase().contains(q)),
        );
      }

      bool matchesPublisherId(String? id) {
        if (id == null) {
          return false;
        }
        final PublisherEntity? p = pubs.where((PublisherEntity p) => p.id == id).firstOrNull;
        if (p == null) {
          return false;
        }
        return p.name.toLowerCase().contains(q) ||
            (p.otherName ?? '').toLowerCase().contains(q);
      }

      bool matchesReaderId(String? id) {
        if (id == null) {
          return false;
        }
        final ReaderEntity? r = readers.where((ReaderEntity r) => r.id == id).firstOrNull;
        if (r == null) {
          return false;
        }
        return r.name.toLowerCase().contains(q) ||
            (r.otherName ?? '').toLowerCase().contains(q);
      }

      bool matchesSequenceVolumeIds(List<String> volumeIds) {
        if (volumeIds.isEmpty) {
          return false;
        }
        final Set<String> sequenceIds = volumes
            .where((SequenceVolumeEntity v) => volumeIds.contains(v.id))
            .map((SequenceVolumeEntity v) => v.sequenceId)
            .toSet();
        return sequences.any(
          (SequenceEntity s) =>
              sequenceIds.contains(s.id) && s.name.toLowerCase().contains(q),
        );
      }

      bool matchesWorkIds(List<String> ids) {
        if (ids.isEmpty) {
          return false;
        }
        return works.any((WorkEntity w) {
          if (!ids.contains(w.id)) {
            return false;
          }
          return w.title.toLowerCase().contains(q) ||
              (w.originalTitle ?? '').toLowerCase().contains(q) ||
              w.contentCategory.name.toLowerCase().contains(q) ||
              (w.language?.name ?? '').toLowerCase().contains(q) ||
              (w.originalLanguage?.name ?? '').toLowerCase().contains(q) ||
              (w.genre?.name ?? '').toLowerCase().contains(q) ||
              (w.notes ?? '').toLowerCase().contains(q) ||
              matchesCreatorIds(w.authorIds) ||
              matchesCreatorIds(w.translatorIds) ||
              matchesSequenceVolumeIds(w.sequenceVolumeIds);
        });
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

        if (matchesCreatorIds(b.authorIds) ||
            matchesCreatorIds(b.translatorIds) ||
            matchesWorkIds(b.workIds) ||
            matchesSequenceVolumeIds(b.sequenceVolumeIds) ||
            matchesPublisherId(b.publisherId) ||
            matchesReaderId(b.readerId)) {
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
