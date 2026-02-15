import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/widgets/snackbar_utils.dart';

import '../../domain/entities/sequence_entity.dart';
import '../../domain/repositories/sequence_repository.dart';
import '../providers/sequence_provider.dart';
import '../widgets/sequence_list_tile.dart';

class SequenceListPage extends ConsumerWidget {
  const SequenceListPage({super.key});

  Future<void> _handleDelete(BuildContext context, WidgetRef ref, String sequenceId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: Theme.of(context).colorScheme.error, size: 48),
        title: const Text('Delete Sequence'),
        content: const Text(
          'Are you sure you want to delete this sequence? This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read<SequenceRepository>(sequenceRepositoryProvider).deleteSequence(sequenceId);
      if (context.mounted) {
        SnackBarUtils.showSuccess(context, 'Sequence deleted successfully');
      }
    } on NoConnectionException catch (e) {
      if (context.mounted) {
        SnackBarUtils.showError(context, e.message);
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.showError(context, 'Delete failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<SequenceEntity>> sequencesAsync = ref.watch(sequencesStreamProvider);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sequences'), centerTitle: true),
      body: sequencesAsync.when(
        data: (List<SequenceEntity> sequences) {
          if (sequences.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.layers_outlined,
                    size: 80,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Sequences Yet',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to add your first sequence',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
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
                  itemCount: sequences.length,
                  itemBuilder: (BuildContext context, int index) {
                    final SequenceEntity sequence = sequences[index];
                    final SequenceStats stats = ref.watch(sequenceStatsProvider(sequence.id));
                    return SequenceListTile(
                      sequence: sequence,
                      onTap: () => context.go('/sequences/${sequence.id}'),
                      onDelete: () => _handleDelete(context, ref, sequence.id),
                      bookCount: stats.bookCount,
                      workCount: stats.workCount,
                    );
                  },
                );
              } else {
                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: sequences.length,
                  itemBuilder: (BuildContext context, int index) {
                    final SequenceEntity sequence = sequences[index];
                    final SequenceStats stats = ref.watch(sequenceStatsProvider(sequence.id));
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: SequenceListTile(
                        sequence: sequence,
                        onTap: () => context.go('/sequences/${sequence.id}'),
                        onDelete: () => _handleDelete(context, ref, sequence.id),
                        bookCount: stats.bookCount,
                        workCount: stats.workCount,
                      ),
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
              Text('Something went wrong', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                '$err',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/sequences/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Sequence'),
      ),
    );
  }
}
