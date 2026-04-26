import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/usecases/work_usecases.dart';
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
      appBar: AppBar(title: const Text('Works'), centerTitle: true),
      body: worksAsync.when(
        data: (List<WorkEntity> works) {
          if (works.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.article_rounded,
                    size: 80,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Works Yet',
                    style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to add your first work',
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
                    mainAxisExtent: 160,
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
        onPressed: () => context.go('/works/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Work'),
      ),
    );
  }
}
