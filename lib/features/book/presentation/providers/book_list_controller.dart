import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../author/domain/entities/author_entity.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../../translator/domain/entities/translator_entity.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../domain/entities/book_entity.dart';
import 'book_provider.dart';

part 'book_list_controller.g.dart';

class BookListState {
  const BookListState({
    required this.displayedBooks,
    required this.totalFiltered,
    required this.searchQuery,
  });

  final List<BookEntity> displayedBooks;
  final int totalFiltered;
  final String searchQuery;

  BookListState copyWith({
    List<BookEntity>? displayedBooks,
    int? totalFiltered,
    String? searchQuery,
  }) =>
      BookListState(
        displayedBooks: displayedBooks ?? this.displayedBooks,
        totalFiltered: totalFiltered ?? this.totalFiltered,
        searchQuery: searchQuery ?? this.searchQuery,
      );
}

@riverpod
class BookListController extends _$BookListController {
  @override
  BookListState build() {
    final List<BookEntity> allBooks = ref.watch(booksStreamProvider).value ?? <BookEntity>[];
    return _calculateState(allBooks, '');
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) {
      return;
    }
    final List<BookEntity> allBooks = ref.read(booksStreamProvider).value ?? <BookEntity>[];
    state = _calculateState(allBooks, query);
  }

  BookListState _calculateState(List<BookEntity> allBooks, String query) {
    // 1. Sort the source list (Case-insensitive)
    final List<BookEntity> sortedBooks = List<BookEntity>.from(allBooks)
      ..sort((BookEntity a, BookEntity b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    List<BookEntity> filtered = sortedBooks;

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();
      
      // Local helper to get names for IDs
      String getAuthorNames(List<String> ids) {
        final List<AuthorEntity> authors = ref.read(authorsStreamProvider).value ?? <AuthorEntity>[];
        return authors.where((AuthorEntity a) => ids.contains(a.id)).map((AuthorEntity a) => a.name).join(' ').toLowerCase();
      }
      
      String getTranslatorNames(List<String> ids) {
        final List<TranslatorEntity> translators = ref.read(translatorsStreamProvider).value ?? <TranslatorEntity>[];
        return translators.where((TranslatorEntity t) => ids.contains(t.id)).map((TranslatorEntity t) => t.name).join(' ').toLowerCase();
      }

      String getPublisherName(String? id) {
        if (id == null) {
          return '';
        }
        final List<PublisherEntity> pubs = ref.read(publishersStreamProvider).value ?? <PublisherEntity>[];
        final PublisherEntity? p = pubs.where((PublisherEntity p) => p.id == id).firstOrNull;
        return p?.name.toLowerCase() ?? '';
      }

      filtered = sortedBooks.where((BookEntity b) {
        final bool matchesTitle = b.title.toLowerCase().contains(q);
        final bool matchesOrigTitle = (b.originalTitle ?? '').toLowerCase().contains(q);
        final bool matchesIsbn = (b.isbn ?? '').toLowerCase().contains(q);
        final bool matchesGenre = (b.genre?.name ?? '').toLowerCase().contains(q);
        final bool matchesLanguage = (b.language?.name ?? '').toLowerCase().contains(q);
        
        if (matchesTitle || matchesOrigTitle || matchesIsbn || matchesGenre || matchesLanguage) {
          return true;
        }

        final bool matchesAuthors = getAuthorNames(b.authorIds).contains(q);
        if (matchesAuthors) {
          return true;
        }

        final bool matchesTranslators = getTranslatorNames(b.translatorIds).contains(q);
        if (matchesTranslators) {
          return true;
        }

        final bool matchesPublisher = getPublisherName(b.publisherId).contains(q);
        if (matchesPublisher) {
          return true;
        }

        return false;
      }).toList();
    }

    return BookListState(
      displayedBooks: filtered,
      totalFiltered: filtered.length,
      searchQuery: query,
    );
  }
}
