import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../creator/domain/entities/creator_entity.dart';
import '../../../creator/presentation/providers/creator_provider.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../domain/entities/work_entity.dart';
import 'work_provider.dart';

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

  WorkListState _calculateState(List<WorkEntity> allWorks, String query) {
    final List<WorkEntity> sortedWorks = List<WorkEntity>.from(
      allWorks,
    )..sort((WorkEntity a, WorkEntity b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    List<WorkEntity> filtered = sortedWorks;

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();

      String getCreatorNames(List<String> ids) {
        final List<CreatorEntity> creators =
            ref.read(creatorsStreamProvider).value ?? <CreatorEntity>[];

        return creators
            .where((CreatorEntity c) => ids.contains(c.id))
            .map((CreatorEntity c) => c.name)
            .join(' ')
            .toLowerCase();
      }

      String getBookName(String? id) {
        if (id == null) {
          return '';
        }

        final List<BookEntity> books = ref.read(booksStreamProvider).value ?? <BookEntity>[];

        return books
                .where((BookEntity b) => b.id == id)
                .map((BookEntity b) => b.title)
                .firstOrNull
                ?.toLowerCase() ??
            '';
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

        final bool matchesAuthors = getCreatorNames(w.authorIds).contains(q);

        if (matchesAuthors) {
          return true;
        }

        final bool matchesTranslators = getCreatorNames(w.translatorIds).contains(q);

        if (matchesTranslators) {
          return true;
        }

        final bool matchesBook = getBookName(w.bookId).contains(q);

        if (matchesBook) {
          return true;
        }

        final bool matchesSequences = getSequenceNames(w.sequenceVolumeIds).contains(q);

        if (matchesSequences) {
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
