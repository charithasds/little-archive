import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/list_page_states.dart';
import '../../../../core/shared/presentation/widgets/search_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/book_usecases.dart';
import '../providers/book_list_controller.dart';
import '../providers/book_provider.dart';
import '../widgets/book_list_tile.dart';

class BookListPage extends ConsumerWidget {
  const BookListPage({super.key});

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, String bookId) async {
    final ThemeData theme = ref.read(activeThemeDataProvider);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 48),
        title: const Text('Remove Book'),
        content: const Text(
          'Are you sure you want to remove this book? This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => context.pop(true),
            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(removeBookUseCaseProvider)(bookId);
      SnackBars.showSuccess('Book removed successfully');
    } on NoConnectionException catch (e) {
      SnackBars.showError(e.message);
    } catch (e) {
      SnackBars.showError('Removal failed: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              icon: Icons.book_rounded,
              title: 'No Books Yet',
              subtitle: 'Tap the button below to add your first book.',
            );
          }

          return Column(
            children: <Widget>[
              SearchField(
                hintText: 'Search books by title, author, genre...',
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
                              onEdit: () => context.push('/books/add', extra: book),
                              onRemove: () => _handleRemove(context, ref, book.id),
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
                              onEdit: () => context.push('/books/add', extra: book),
                              onRemove: () => _handleRemove(context, ref, book.id),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
            ],
          );
        },
        loading: () => const ListLoadingState(),
        error: (Object err, StackTrace stack) => ListErrorState(error: err),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Buttons.getPrimaryActionBackgroundColor(theme),
        foregroundColor: Buttons.getPrimaryActionForegroundColor(theme),
        onPressed: () => context.go('/books/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Book'),
      ),
    );
  }
}
