import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/sequence_entity.dart';
import 'sequence_provider.dart';

part 'sequence_list_controller.g.dart';

class SequenceListState {
  const SequenceListState({
    required this.displayedSequences,
    required this.totalFiltered,
    required this.searchQuery,
  });

  final List<SequenceEntity> displayedSequences;
  final int totalFiltered;
  final String searchQuery;
}

@riverpod
class SequenceListController extends _$SequenceListController {
  @override
  SequenceListState build() {
    final List<SequenceEntity> allSequences =
        ref.watch(sequencesStreamProvider).value ?? <SequenceEntity>[];

    return _calculateState(allSequences, '');
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) {
      return;
    }

    final List<SequenceEntity> allSequences =
        ref.read(sequencesStreamProvider).value ?? <SequenceEntity>[];

    state = _calculateState(allSequences, query);
  }

  SequenceListState _calculateState(List<SequenceEntity> allSequences, String query) {
    final List<SequenceEntity> sortedSequences = List<SequenceEntity>.from(allSequences)
      ..sort(
        (SequenceEntity a, SequenceEntity b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    List<SequenceEntity> filtered = sortedSequences;

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();

      filtered = allSequences.where((SequenceEntity s) {
        final bool matchesName = s.name.toLowerCase().contains(q);
        final bool matchesOtherName = (s.otherName ?? '').toLowerCase().contains(q);
        final bool matchesNotes = (s.notes ?? '').toLowerCase().contains(q);

        return matchesName || matchesOtherName || matchesNotes;
      }).toList();
    }

    return SequenceListState(
      displayedSequences: filtered,
      totalFiltered: filtered.length,
      searchQuery: query,
    );
  }
}
