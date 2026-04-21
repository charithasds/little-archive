import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../../features/author/domain/entities/author_entity.dart';
import '../../../../features/author/presentation/providers/author_provider.dart';
import '../../../../features/translator/domain/entities/translator_entity.dart';
import '../../../../features/translator/presentation/providers/translator_provider.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';
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
      await ref.read<BookRepository>(bookRepositoryProvider).removeBook(bookId);
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
    final List<AuthorEntity> authors = ref.watch(authorsStreamProvider).value ?? <AuthorEntity>[];
    final List<TranslatorEntity> translators =
        ref.watch(translatorsStreamProvider).value ?? <TranslatorEntity>[];

    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Books'), centerTitle: true),
      body: booksAsync.when(
        data: (List<BookEntity> books) {
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.book_rounded,
                    size: 80,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Books Yet',
                    style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to add your first book',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth < 600) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: books.length,
                  itemBuilder: (BuildContext context, int index) {
                    final BookEntity book = books[index];
                    String? creatorName;
                    if (book.isTranslation) {
                      if (book.translatorIds.isNotEmpty) {
                        creatorName = translators
                            .where((TranslatorEntity t) => t.id == book.translatorIds.first)
                            .firstOrNull
                            ?.name;
                      }
                    } else {
                      if (book.authorIds.isNotEmpty) {
                        creatorName = authors
                            .where((AuthorEntity a) => a.id == book.authorIds.first)
                            .firstOrNull
                            ?.name;
                      }
                    }
                    return BookListTile(
                      book: book,
                      firstCreatorName: creatorName,
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
                    String? creatorName;
                    if (book.isTranslation) {
                      if (book.translatorIds.isNotEmpty) {
                        creatorName = translators
                            .where((TranslatorEntity t) => t.id == book.translatorIds.first)
                            .firstOrNull
                            ?.name;
                      }
                    } else {
                      if (book.authorIds.isNotEmpty) {
                        creatorName = authors
                            .where((AuthorEntity a) => a.id == book.authorIds.first)
                            .firstOrNull
                            ?.name;
                      }
                    }
                    return BookListTile(
                      book: book,
                      firstCreatorName: creatorName,
                      onTap: () => context.go('/books/${book.id}'),
                      onEdit: () => context.push('/books/add', extra: book),
                      onRemove: () => _handleRemove(context, ref, book.id),
                    );
                  },
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object err, StackTrace stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.error_rounded, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('Something went wrong', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                '$err',
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
