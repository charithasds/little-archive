import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/sequence_entity.dart';
import 'sequence_provider.dart';

part 'sequence_list_controller.g.dart';

class SequenceListState {
  const SequenceListState({
    required this.displayedSequences,
    required this.totalFiltered,
    required this.currentPage,
    required this.pageSize,
    required this.searchQuery,
  });

  final List<SequenceEntity> displayedSequences;
  final int totalFiltered;
  final int currentPage;
  final int pageSize;
  final String searchQuery;

  int get totalPages => (totalFiltered / pageSize).ceil();
}

@riverpod
class SequenceListController extends _$SequenceListController {
  static const int _defaultPageSize = 20;

  @override
  SequenceListState build() {
    final List<SequenceEntity> allSequences = ref.watch(sequencesStreamProvider).value ?? <SequenceEntity>[];
    return _calculateState(allSequences, '', 1, _defaultPageSize);
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) {
      return;
    }
    final List<SequenceEntity> allSequences = ref.read(sequencesStreamProvider).value ?? <SequenceEntity>[];
    state = _calculateState(allSequences, query, 1, state.pageSize);
  }

  void setPage(int page) {
    if (page < 1 || page > state.totalPages || page == state.currentPage) {
      return;
    }
    final List<SequenceEntity> allSequences = ref.read(sequencesStreamProvider).value ?? <SequenceEntity>[];
    state = _calculateState(allSequences, state.searchQuery, page, state.pageSize);
  }

  SequenceListState _calculateState(List<SequenceEntity> allSequences, String query, int page, int pageSize) {
    List<SequenceEntity> filtered = allSequences;

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();
      filtered = allSequences.where((SequenceEntity s) {
        final bool matchesName = s.name.toLowerCase().contains(q);
        final bool matchesOtherName = (s.otherName ?? '').toLowerCase().contains(q);
        return matchesName || matchesOtherName;
      }).toList();
    }

    final int totalFiltered = filtered.length;
    final int safePage = page > (totalFiltered / pageSize).ceil() ? 1 : page;
    
    final int startIndex = (safePage - 1) * pageSize;
    final List<SequenceEntity> paged = filtered.skip(startIndex).take(pageSize).toList();

    return SequenceListState(
      displayedSequences: paged,
      totalFiltered: totalFiltered,
      currentPage: safePage,
      pageSize: pageSize,
      searchQuery: query,
    );
  }
}
