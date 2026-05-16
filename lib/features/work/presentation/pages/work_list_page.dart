import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/list_page_states.dart';
import '../../../../core/shared/presentation/widgets/search_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/usecases/work_usecases.dart';
import '../providers/work_list_controller.dart';
import '../providers/work_provider.dart';
import '../widgets/work_list_tile.dart';

class WorkListPage extends ConsumerWidget {
  const WorkListPage({super.key});

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, String workId) async {
    final ThemeData theme = ref.read(activeThemeDataProvider);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 48),
        title: const Text('Remove Work'),
        content: const Text(
          'Are you sure you want to remove this work? This action cannot be undone.',
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
      await ref.read(removeWorkUseCaseProvider)(workId);
      SnackBars.showSuccess('Work removed successfully');
    } on NoConnectionException catch (e) {
      SnackBars.showError(e.message);
    } catch (e) {
      SnackBars.showError('Removal failed: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<WorkEntity>> worksAsync = ref.watch(worksStreamProvider);

    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Works'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.primary,
        scrolledUnderElevation: 1,
      ),
      body: worksAsync.when(
        data: (_) {
          final WorkListState state = ref.watch(workListControllerProvider);
          final List<WorkEntity> works = state.displayedWorks;

          if (works.isEmpty && state.searchQuery.isEmpty) {
            return const ListEmptyState(
              icon: Icons.collections_bookmark_rounded,
              title: 'No Works Yet',
              subtitle: 'Tap the button below to add your first work.',
            );
          }

          return Column(
            children: <Widget>[
              SearchField(
                hintText: 'Search works by title, author...',
                onChanged: (String query) =>
                    ref.read(workListControllerProvider.notifier).setSearchQuery(query),
              ),
              if (works.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No works match your search.',
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
                          itemCount: works.length,
                          itemBuilder: (BuildContext context, int index) {
                            final WorkEntity work = works[index];
                            return WorkListTile(
                              work: work,
                              onTap: () => context.go('/works/${work.id}'),
                              onEdit: () => context.push('/works/add', extra: work),
                              onRemove: () => _handleRemove(context, ref, work.id),
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
                          itemCount: works.length,
                          itemBuilder: (BuildContext context, int index) {
                            final WorkEntity work = works[index];
                            return WorkListTile(
                              work: work,
                              onTap: () => context.go('/works/${work.id}'),
                              onEdit: () => context.push('/works/add', extra: work),
                              onRemove: () => _handleRemove(context, ref, work.id),
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
        onPressed: () => context.go('/works/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Work'),
      ),
    );
  }
}
