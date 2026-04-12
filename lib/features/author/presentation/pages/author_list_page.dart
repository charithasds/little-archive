import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/button_styles.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/repositories/author_repository.dart';
import '../providers/author_provider.dart';
import '../widgets/author_list_tile.dart';

class AuthorListPage extends ConsumerWidget {
  const AuthorListPage({super.key});

  Future<void> _handleDelete(BuildContext context, WidgetRef ref, String authorId) async {
    final ThemeData theme = ref.read(activeThemeDataProvider);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 48),
        title: const Text('Delete Author'),
        content: const Text(
          'Are you sure you want to delete this author? This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read<AuthorRepository>(authorRepositoryProvider).deleteAuthor(authorId);
      if (context.mounted) {
        SnackBars.showSuccess(context, 'Author deleted successfully');
      }
    } on NoConnectionException catch (e) {
      if (context.mounted) {
        SnackBars.showError(context, e.message);
      }
    } catch (e) {
      if (context.mounted) {
        SnackBars.showError(context, 'Delete failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<AuthorEntity>> authorsAsync = ref.watch(authorsStreamProvider);

    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Authors'), centerTitle: true),
      body: authorsAsync.when(
        data: (List<AuthorEntity> authors) {
          if (authors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.person_outline_rounded,
                    size: 80,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Authors Yet',
                    style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to add your first author',
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
                  itemCount: authors.length,
                  itemBuilder: (BuildContext context, int index) {
                    final AuthorEntity author = authors[index];
                    return AuthorListTile(
                      author: author,
                      onTap: () => context.go('/authors/${author.id}'),
                      onEdit: () => context.push('/authors/add', extra: author),
                      onDelete: () => _handleDelete(context, ref, author.id),
                    );
                  },
                );
              } else {
                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 600,
                    mainAxisExtent: 140,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: authors.length,
                  itemBuilder: (BuildContext context, int index) {
                    final AuthorEntity author = authors[index];
                    return AuthorListTile(
                      author: author,
                      onTap: () => context.go('/authors/${author.id}'),
                      onEdit: () => context.push('/authors/add', extra: author),
                      onDelete: () => _handleDelete(context, ref, author.id),
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
              Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
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
        backgroundColor: ButtonStyles.getPrimaryActionBackgroundColor(theme),
        foregroundColor: ButtonStyles.getPrimaryActionForegroundColor(theme),
        onPressed: () => context.go('/authors/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Author'),
      ),
    );
  }
}
