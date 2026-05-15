import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/reader_entity.dart';
import 'reader_provider.dart';

part 'reader_list_controller.g.dart';

class ReaderListState {
  const ReaderListState({
    required this.displayedReaders,
    required this.totalFiltered,
    required this.searchQuery,
  });

  final List<ReaderEntity> displayedReaders;
  final int totalFiltered;
  final String searchQuery;
}

@riverpod
class ReaderListController extends _$ReaderListController {
  @override
  ReaderListState build() {
    final List<ReaderEntity> allReaders = ref.watch(readersStreamProvider).value ?? <ReaderEntity>[];
    return _calculateState(allReaders, '');
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) {
      return;
    }
    final List<ReaderEntity> allReaders = ref.read(readersStreamProvider).value ?? <ReaderEntity>[];
    state = _calculateState(allReaders, query);
  }

  ReaderListState _calculateState(List<ReaderEntity> allReaders, String query) {
    // Sort alphabetically (Case-insensitive)
    final List<ReaderEntity> sortedReaders = List<ReaderEntity>.from(allReaders)
      ..sort((ReaderEntity a, ReaderEntity b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    List<ReaderEntity> filtered = sortedReaders;

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();
      filtered = sortedReaders.where((ReaderEntity r) {
        final bool matchesName = r.name.toLowerCase().contains(q);
        final bool matchesOtherName = (r.otherName ?? '').toLowerCase().contains(q);
        final bool matchesEmail = (r.email ?? '').toLowerCase().contains(q);
        final bool matchesPhone = (r.phoneNumber ?? '').toLowerCase().contains(q);
        return matchesName || matchesOtherName || matchesEmail || matchesPhone;
      }).toList();
    }

    return ReaderListState(
      displayedReaders: filtered,
      totalFiltered: filtered.length,
      searchQuery: query,
    );
  }
}
