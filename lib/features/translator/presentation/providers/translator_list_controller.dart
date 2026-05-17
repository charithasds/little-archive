import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/translator_entity.dart';
import 'translator_provider.dart';

part 'translator_list_controller.g.dart';

class TranslatorListState {
  const TranslatorListState({
    required this.displayedTranslators,
    required this.totalFiltered,
    required this.searchQuery,
  });

  final List<TranslatorEntity> displayedTranslators;
  final int totalFiltered;
  final String searchQuery;
}

@riverpod
class TranslatorListController extends _$TranslatorListController {
  @override
  TranslatorListState build() {
    final List<TranslatorEntity> allTranslators =
        ref.watch(translatorsStreamProvider).value ?? <TranslatorEntity>[];

    return _calculateState(allTranslators, '');
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) {
      return;
    }

    final List<TranslatorEntity> allTranslators =
        ref.read(translatorsStreamProvider).value ?? <TranslatorEntity>[];

    state = _calculateState(allTranslators, query);
  }

  TranslatorListState _calculateState(List<TranslatorEntity> allTranslators, String query) {
    final List<TranslatorEntity> sortedTranslators = List<TranslatorEntity>.from(allTranslators)
      ..sort(
        (TranslatorEntity a, TranslatorEntity b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    List<TranslatorEntity> filtered = sortedTranslators;

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();

      filtered = sortedTranslators.where((TranslatorEntity t) {
        final bool matchesName = t.name.toLowerCase().contains(q);
        final bool matchesOtherName = (t.otherName ?? '').toLowerCase().contains(q);
        final bool matchesWebsite = (t.website ?? '').toLowerCase().contains(q);

        return matchesName || matchesOtherName || matchesWebsite;
      }).toList();
    }

    return TranslatorListState(
      displayedTranslators: filtered,
      totalFiltered: filtered.length,
      searchQuery: query,
    );
  }
}
