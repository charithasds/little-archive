import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../creator/domain/entities/creator_entity.dart';
import '../../../creator/presentation/providers/creator_provider.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../../reader/domain/entities/reader_entity.dart';
import '../../../reader/presentation/providers/reader_provider.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../domain/entities/work_entity.dart';
import 'work_provider.dart';
import 'work_usecase_providers.dart';

part 'work_list_controller.g.dart';

class WorkListState {
  const WorkListState({
    required this.displayedWorks,
    required this.totalFiltered,
    required this.searchQuery,
  });

  final List<WorkEntity> displayedWorks;
  final int totalFiltered;
  final String searchQuery;
}

@riverpod
class WorkListController extends _$WorkListController {
  @override
  WorkListState build() {
    final List<WorkEntity> allWorks = ref.watch(worksStreamProvider).value ?? <WorkEntity>[];

    ref.watch(creatorsStreamProvider);
    ref.watch(booksStreamProvider);
    ref.watch(publishersStreamProvider);
    ref.watch(readersStreamProvider);
    ref.watch(sequencesStreamProvider);
    ref.watch(allSequenceVolumesStreamProvider);

    return _calculateState(allWorks, '');
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) {
      return;
    }

    final List<WorkEntity> allWorks = ref.read(worksStreamProvider).value ?? <WorkEntity>[];

    state = _calculateState(allWorks, query);
  }

  Future<void> removeWork(String id) => ref.read(removeWorkUseCaseProvider)(id);

  WorkListState _calculateState(List<WorkEntity> allWorks, String query) {
    final List<WorkEntity> sortedWorks = List<WorkEntity>.from(
      allWorks,
    )..sort((WorkEntity a, WorkEntity b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    List<WorkEntity> filtered = sortedWorks;

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();

      final List<CreatorEntity> creators =
          ref.read(creatorsStreamProvider).value ?? <CreatorEntity>[];
      final List<BookEntity> books = ref.read(booksStreamProvider).value ?? <BookEntity>[];
      final List<PublisherEntity> pubs =
          ref.read(publishersStreamProvider).value ?? <PublisherEntity>[];
      final List<ReaderEntity> readers =
          ref.read(readersStreamProvider).value ?? <ReaderEntity>[];
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

      bool matchesBook(String? id) {
        if (id == null) {
          return false;
        }
        final BookEntity? b = books.where((BookEntity b) => b.id == id).firstOrNull;
        if (b == null) {
          return false;
        }

        final bool matchesBookDirectFields =
            b.title.toLowerCase().contains(q) ||
            b.compilationType.name.toLowerCase().contains(q) ||
            (b.language?.name ?? '').toLowerCase().contains(q) ||
            (b.genre?.name ?? '').toLowerCase().contains(q) ||
            (b.isbn ?? '').toLowerCase().contains(q) ||
            (b.noOfPages ?? '').toString().toLowerCase().contains(q) ||
            (b.originalTitle ?? '').toLowerCase().contains(q) ||
            (b.originalLanguage?.name ?? '').toLowerCase().contains(q) ||
            b.collectionStatus.name.toLowerCase().contains(q) ||
            b.readingStatus.name.toLowerCase().contains(q) ||
            (b.notes ?? '').toLowerCase().contains(q);

        if (matchesBookDirectFields) {
          return true;
        }

        return matchesCreatorIds(b.authorIds) ||
            matchesCreatorIds(b.translatorIds) ||
            matchesSequenceVolumeIds(b.sequenceVolumeIds) ||
            matchesPublisherId(b.publisherId) ||
            matchesReaderId(b.readerId);
      }

      filtered = sortedWorks.where((WorkEntity w) {
        final bool matchesTitle = w.title.toLowerCase().contains(q);
        final bool matchesContentCategory = w.contentCategory.name.toLowerCase().contains(q);
        final bool matchesLanguage = (w.language?.name ?? '').toLowerCase().contains(q);
        final bool matchesGenre = (w.genre?.name ?? '').toLowerCase().contains(q);
        final bool matchesOriginalTitle = (w.originalTitle ?? '').toLowerCase().contains(q);
        final bool matchesOriginalLanguage = (w.originalLanguage?.name ?? '')
            .toLowerCase()
            .contains(q);
        final bool matchesNotes = (w.notes ?? '').toLowerCase().contains(q);

        if (matchesTitle ||
            matchesContentCategory ||
            matchesLanguage ||
            matchesGenre ||
            matchesOriginalTitle ||
            matchesOriginalLanguage ||
            matchesNotes) {
          return true;
        }

        if (matchesCreatorIds(w.authorIds) ||
            matchesCreatorIds(w.translatorIds) ||
            matchesBook(w.bookId) ||
            matchesSequenceVolumeIds(w.sequenceVolumeIds)) {
          return true;
        }

        return false;
      }).toList();
    }

    return WorkListState(
      displayedWorks: filtered,
      totalFiltered: filtered.length,
      searchQuery: query,
    );
  }
}
