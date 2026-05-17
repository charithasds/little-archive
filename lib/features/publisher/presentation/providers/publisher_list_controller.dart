import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/publisher_entity.dart';
import 'publisher_provider.dart';

part 'publisher_list_controller.g.dart';

class PublisherListState {
  const PublisherListState({
    required this.displayedPublishers,
    required this.totalFiltered,
    required this.searchQuery,
  });

  final List<PublisherEntity> displayedPublishers;
  final int totalFiltered;
  final String searchQuery;
}

@riverpod
class PublisherListController extends _$PublisherListController {
  @override
  PublisherListState build() {
    final List<PublisherEntity> allPublishers =
        ref.watch(publishersStreamProvider).value ?? <PublisherEntity>[];

    return _calculateState(allPublishers, '');
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) {
      return;
    }

    final List<PublisherEntity> allPublishers =
        ref.read(publishersStreamProvider).value ?? <PublisherEntity>[];

    state = _calculateState(allPublishers, query);
  }

  PublisherListState _calculateState(List<PublisherEntity> allPublishers, String query) {
    final List<PublisherEntity> sortedPublishers = List<PublisherEntity>.from(allPublishers)
      ..sort(
        (PublisherEntity a, PublisherEntity b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    List<PublisherEntity> filtered = sortedPublishers;

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();

      filtered = sortedPublishers.where((PublisherEntity p) {
        final bool matchesName = p.name.toLowerCase().contains(q);
        final bool matchesOtherName = (p.otherName ?? '').toLowerCase().contains(q);
        final bool matchesWebsite = (p.website ?? '').toLowerCase().contains(q);
        final bool matchesEmail = (p.email ?? '').toLowerCase().contains(q);
        final bool matchesPhone = (p.phoneNumber ?? '').toLowerCase().contains(q);

        return matchesName || matchesOtherName || matchesWebsite || matchesEmail || matchesPhone;
      }).toList();
    }

    return PublisherListState(
      displayedPublishers: filtered,
      totalFiltered: filtered.length,
      searchQuery: query,
    );
  }
}
