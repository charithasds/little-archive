import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/author_entity.dart';
import 'author_provider.dart';

part 'author_list_controller.g.dart';

class AuthorListState {
  const AuthorListState({
    required this.displayedAuthors,
    required this.totalFiltered,
    required this.searchQuery,
  });

  final List<AuthorEntity> displayedAuthors;
  final int totalFiltered;
  final String searchQuery;
}

@riverpod
class AuthorListController extends _$AuthorListController {
  @override
  AuthorListState build() {
    final List<AuthorEntity> allAuthors =
        ref.watch(authorsStreamProvider).value ?? <AuthorEntity>[];
    return _calculateState(allAuthors, '');
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) {
      return;
    }
    final List<AuthorEntity> allAuthors = ref.read(authorsStreamProvider).value ?? <AuthorEntity>[];
    state = _calculateState(allAuthors, query);
  }

  AuthorListState _calculateState(List<AuthorEntity> allAuthors, String query) {
    // Sort alphabetically (Case-insensitive)
    final List<AuthorEntity> sortedAuthors = List<AuthorEntity>.from(allAuthors)
      ..sort(
        (AuthorEntity a, AuthorEntity b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

    List<AuthorEntity> filtered = sortedAuthors;

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();
      filtered = sortedAuthors.where((AuthorEntity a) {
        final bool matchesName = a.name.toLowerCase().contains(q);
        final bool matchesOtherName = (a.otherName ?? '').toLowerCase().contains(q);
        final bool matchesWebsite = (a.website ?? '').toLowerCase().contains(q);
        return matchesName || matchesOtherName || matchesWebsite;
      }).toList();
    }

    return AuthorListState(
      displayedAuthors: filtered,
      totalFiltered: filtered.length,
      searchQuery: query,
    );
  }
}
