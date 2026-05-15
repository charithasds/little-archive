import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/list_page_states.dart';
import '../../../../core/shared/presentation/widgets/search_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/usecases/author_usecases.dart';
import '../providers/author_list_controller.dart';
import '../providers/author_provider.dart';
import '../widgets/author_list_tile.dart';

class AuthorListPage extends ConsumerWidget {
  const AuthorListPage({super.key});

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, String authorId) async {
    final ThemeData theme = ref.read(activeThemeDataProvider);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 48),
        title: const Text('Remove Author'),
        content: const Text(
          'Are you sure you want to remove this author? This action cannot be undone.',
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
      await ref.read(removeAuthorUseCaseProvider)(authorId);
      SnackBars.showSuccess('Author removed successfully');
    } on NoConnectionException catch (e) {
      SnackBars.showError(e.message);
    } catch (e) {
      SnackBars.showError('Removal failed: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<AuthorEntity>> authorsAsync = ref.watch(authorsStreamProvider);

    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Authors'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.primary,
        scrolledUnderElevation: 1,
      ),
      body: authorsAsync.when(
        data: (_) {
          final AuthorListState state = ref.watch(authorListControllerProvider);
          final List<AuthorEntity> authors = state.displayedAuthors;

          if (authors.isEmpty && state.searchQuery.isEmpty) {
            return const ListEmptyState(
              icon: Icons.person_rounded,
              title: 'No Authors Yet',
              subtitle: 'Tap the button below to add your first author.',
            );
          }

          return Column(
            children: <Widget>[
              SearchField(
                hintText: 'Search authors by name, website...',
                onChanged: (String query) =>
                    ref.read(authorListControllerProvider.notifier).setSearchQuery(query),
              ),
              if (authors.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No authors match your search.',
                      style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
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
                          itemCount: authors.length,
                          itemBuilder: (BuildContext context, int index) {
                            final AuthorEntity author = authors[index];
                            return AuthorListTile(
                              author: author,
                              onTap: () => context.go('/authors/${author.id}'),
                              onEdit: () => context.push('/authors/add', extra: author),
                              onRemove: () => _handleRemove(context, ref, author.id),
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
                              onRemove: () => _handleRemove(context, ref, author.id),
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
        onPressed: () => context.go('/authors/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Author'),
      ),
    );
  }
}
