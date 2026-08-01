import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/creator_entity.dart';
import 'creator_provider.dart';

part 'creator_list_controller.g.dart';

class CreatorListState {
  const CreatorListState({
    required this.displayedCreators,
    required this.totalFiltered,
    required this.searchQuery,
  });

  final List<CreatorEntity> displayedCreators;
  final int totalFiltered;
  final String searchQuery;
}

@riverpod
class CreatorListController extends _$CreatorListController {
  @override
  CreatorListState build() {
    final List<CreatorEntity> allCreators =
        ref.watch(creatorsStreamProvider).value ?? <CreatorEntity>[];

    return _calculateState(allCreators, '');
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) {
      return;
    }

    final List<CreatorEntity> allCreators = ref.read(creatorsStreamProvider).value ?? <CreatorEntity>[];

    state = _calculateState(allCreators, query);
  }

  CreatorListState _calculateState(List<CreatorEntity> allCreators, String query) {
    final List<CreatorEntity> sortedCreators = List<CreatorEntity>.from(allCreators)
      ..sort(
        (CreatorEntity a, CreatorEntity b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    List<CreatorEntity> filtered = sortedCreators;

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();

      filtered = sortedCreators.where((CreatorEntity a) {
        final bool matchesName = a.name.toLowerCase().contains(q);
        final bool matchesOtherName = (a.otherName ?? '').toLowerCase().contains(q);
        final bool matchesWebsite = (a.website ?? '').toLowerCase().contains(q);

        return matchesName || matchesOtherName || matchesWebsite;
      }).toList();
    }

    return CreatorListState(
      displayedCreators: filtered,
      totalFiltered: filtered.length,
      searchQuery: query,
    );
  }
}
