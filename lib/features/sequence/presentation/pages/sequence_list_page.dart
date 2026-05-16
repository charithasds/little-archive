import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/list_page_states.dart';
import '../../../../core/shared/presentation/widgets/pagination_controls.dart';
import '../../../../core/shared/presentation/widgets/search_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/sequence_entity.dart';
import '../../domain/usecases/sequence_usecases.dart';
import '../providers/sequence_list_controller.dart';
import '../providers/sequence_provider.dart';
import '../widgets/sequence_list_tile.dart';

class SequenceListPage extends ConsumerWidget {
  const SequenceListPage({super.key});

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, String sequenceId) async {
    final ThemeData theme = ref.read(activeThemeDataProvider);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 48),
        title: const Text('Remove Sequence'),
        content: const Text(
          'Are you sure you want to remove this sequence? This action cannot be undone.',
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
      await ref.read(removeSequenceUseCaseProvider)(sequenceId);
      SnackBars.showSuccess('Sequence removed successfully');
    } on NoConnectionException catch (e) {
      SnackBars.showError(e.message);
    } catch (e) {
      SnackBars.showError('Removal failed: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<SequenceEntity>> sequencesAsync = ref.watch(sequencesStreamProvider);
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Sequences'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.primary,
        scrolledUnderElevation: 1,
      ),
      body: sequencesAsync.when(
        data: (_) {
          final SequenceListState state = ref.watch(sequenceListControllerProvider);
          final List<SequenceEntity> sequences = state.displayedSequences;

          if (sequences.isEmpty && state.searchQuery.isEmpty) {
            return const ListEmptyState(
              icon: Icons.format_list_numbered_rounded,
              title: 'No Sequences Yet',
              subtitle: 'Tap the button below to add your first sequence.',
            );
          }

          return Column(
            children: <Widget>[
              SearchField(
                hintText: 'Search sequences by name...',
                onChanged: (String query) =>
                    ref.read(sequenceListControllerProvider.notifier).setSearchQuery(query),
              ),
              if (sequences.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No sequences match your search.',
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
                          itemCount: sequences.length,
                          itemBuilder: (BuildContext context, int index) {
                            final SequenceEntity sequence = sequences[index];
                            return SequenceListTile(
                              sequence: sequence,
                              onTap: () => context.go('/sequences/${sequence.id}'),
                              onEdit: () => context.push('/sequences/add', extra: sequence),
                              onRemove: () => _handleRemove(context, ref, sequence.id),
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
                          itemCount: sequences.length,
                          itemBuilder: (BuildContext context, int index) {
                            final SequenceEntity sequence = sequences[index];
                            return SequenceListTile(
                              sequence: sequence,
                              onTap: () => context.go('/sequences/${sequence.id}'),
                              onEdit: () => context.push('/sequences/add', extra: sequence),
                              onRemove: () => _handleRemove(context, ref, sequence.id),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              PaginationControls(
                currentPage: state.currentPage,
                totalPages: state.totalPages,
                onPageChanged: (int page) =>
                    ref.read(sequenceListControllerProvider.notifier).setPage(page),
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
        onPressed: () => context.go('/sequences/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Sequence'),
      ),
    );
  }
}
