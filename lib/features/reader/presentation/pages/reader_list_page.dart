import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/snackbar_utils.dart';

import '../../domain/entities/reader_entity.dart';
import '../../domain/repositories/reader_repository.dart';
import '../providers/reader_provider.dart';
import '../widgets/reader_list_tile.dart';

class ReaderListPage extends ConsumerWidget {
  const ReaderListPage({super.key});

  Future<void> _handleDelete(BuildContext context, WidgetRef ref, String readerId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: Theme.of(context).colorScheme.error, size: 48),
        title: const Text('Delete Reader'),
        content: const Text(
          'Are you sure you want to delete this reader? This action cannot be undone.',
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
      await ref.read<ReaderRepository>(readerRepositoryProvider).deleteReader(readerId);
      if (context.mounted) {
        SnackBarUtils.showSuccess(context, 'Reader deleted successfully');
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
    final AsyncValue<List<ReaderEntity>> readersAsync = ref.watch(readersStreamProvider);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Readers'), centerTitle: true),
      body: readersAsync.when(
        data: (List<ReaderEntity> readers) {
          if (readers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.face_outlined,
                    size: 80,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Readers Yet',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to add your first reader',
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
                  itemCount: readers.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ReaderEntity reader = readers[index];
                    return ReaderListTile(
                      reader: reader,
                      onTap: () => context.go('/readers/${reader.id}'),
                      onDelete: () => _handleDelete(context, ref, reader.id),
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
                  itemCount: readers.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ReaderEntity reader = readers[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: ReaderListTile(
                        reader: reader,
                        onTap: () => context.go('/readers/${reader.id}'),
                        onDelete: () => _handleDelete(context, ref, reader.id),
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
        onPressed: () => context.go('/readers/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Reader'),
      ),
    );
  }
}
