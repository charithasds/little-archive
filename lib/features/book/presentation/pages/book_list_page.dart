import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/dialogs.dart';
import '../../../../core/shared/presentation/widgets/list_empty_state.dart';
import '../../../../core/shared/presentation/widgets/list_error_state.dart';
import '../../../../core/shared/presentation/widgets/list_loading_state.dart';
import '../../../../core/shared/presentation/widgets/search_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/book_usecases.dart';
import '../providers/book_list_controller.dart';
import '../providers/book_provider.dart';
import '../widgets/book_list_tile.dart';

class BookListPage extends ConsumerStatefulWidget {
  const BookListPage({super.key});

  @override
  ConsumerState<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends ConsumerState<BookListPage> {
  bool _isExtended = true;

  Future<void> _handleRemove(String bookId, String bookTitle) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Book',
      entityName: bookTitle,
      onConfirm: () async {
        await ref.read(removeBookUseCaseProvider)(bookId);
        ref.invalidate(bookCountProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<BookEntity>> booksAsync = ref.watch(booksStreamProvider);
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Books'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.primary,
        scrolledUnderElevation: 1,
      ),
      body: booksAsync.when(
        data: (_) {
          final BookListState state = ref.watch(bookListControllerProvider);
          final List<BookEntity> books = state.displayedBooks;

          if (books.isEmpty && state.searchQuery.isEmpty) {
            return const ListEmptyState(
              icon: FontAwesomeIcons.book,
              title: 'No Books Yet',
              subtitle: 'Tap the button below to add your first book.',
            );
          }

          return NotificationListener<UserScrollNotification>(
            onNotification: (UserScrollNotification notification) {
              if (notification.direction == ScrollDirection.reverse) {
                if (_isExtended) {
                  setState(() => _isExtended = false);
                }
              } else if (notification.direction == ScrollDirection.forward) {
                if (!_isExtended) {
                  setState(() => _isExtended = true);
                }
              }

              return true;
            },
            child: Column(
              children: <Widget>[
                SearchField(
                  hintText: 'Search',
                  onChanged: (String query) =>
                      ref.read(bookListControllerProvider.notifier).setSearchQuery(query),
                ),
                if (books.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No books match your search.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        if (constraints.maxWidth < 600) {
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: books.length,
                            itemBuilder: (BuildContext context, int index) {
                              final BookEntity book = books[index];

                              return BookListTile(
                                book: book,
                                onTap: () => context.go('/books/${book.id}'),
                                onEdit: () => context.push('/books/upsert', extra: book),
                                onRemove: () => _handleRemove(book.id, book.title),
                              );
                            },
                          );
                        } else {
                          return GridView.builder(
                            padding: const EdgeInsets.all(24),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 600,
                              mainAxisExtent: 160,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                            ),
                            itemCount: books.length,
                            itemBuilder: (BuildContext context, int index) {
                              final BookEntity book = books[index];

                              return BookListTile(
                                book: book,
                                onTap: () => context.go('/books/${book.id}'),
                                onEdit: () => context.push('/books/upsert', extra: book),
                                onRemove: () => _handleRemove(book.id, book.title),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const ListLoadingState(),
        error: (Object err, StackTrace stack) => ListErrorState(error: err),
      ),
      floatingActionButton: FloatingActionButton.extended(
        isExtended: _isExtended,
        backgroundColor: Buttons.getPrimaryActionBackgroundColor(theme),
        foregroundColor: Buttons.getPrimaryActionForegroundColor(theme),
        onPressed: () => context.go('/books/upsert'),
        icon: const FaIcon(FontAwesomeIcons.plus),
        label: const Text('Add Book'),
      ),
    );
  }
}
