import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../author/domain/entities/author_entity.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../translator/domain/entities/translator_entity.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
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
    // Sort alphabetically (Case-insensitive)
    final List<WorkEntity> sortedWorks = List<WorkEntity>.from(
      allWorks,
    )..sort((WorkEntity a, WorkEntity b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    List<WorkEntity> filtered = sortedWorks;

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();

      String getAuthorNames(List<String> ids) {
        final List<AuthorEntity> authors =
            ref.read(authorsStreamProvider).value ?? <AuthorEntity>[];
        return authors
            .where((AuthorEntity a) => ids.contains(a.id))
            .map((AuthorEntity a) => a.name)
            .join(' ')
            .toLowerCase();
      }

      String getTranslatorNames(List<String> ids) {
        final List<TranslatorEntity> translators =
            ref.read(translatorsStreamProvider).value ?? <TranslatorEntity>[];
        return translators
            .where((TranslatorEntity t) => ids.contains(t.id))
            .map((TranslatorEntity t) => t.name)
            .join(' ')
            .toLowerCase();
      }

      filtered = sortedWorks.where((WorkEntity w) {
        final bool matchesTitle = w.title.toLowerCase().contains(q);
        final bool matchesOrigTitle = (w.originalTitle ?? '').toLowerCase().contains(q);
        final bool matchesGenre = (w.genre?.name ?? '').toLowerCase().contains(q);
        final bool matchesLanguage = (w.language?.name ?? '').toLowerCase().contains(q);

        if (matchesTitle || matchesOrigTitle || matchesGenre || matchesLanguage) {
          return true;
        }

        final bool matchesAuthors = getAuthorNames(w.authorIds).contains(q);
        if (matchesAuthors) {
          return true;
        }

        final bool matchesTranslators = getTranslatorNames(w.translatorIds).contains(q);
        if (matchesTranslators) {
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
