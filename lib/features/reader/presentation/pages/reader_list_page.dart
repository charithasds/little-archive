import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/list_page_states.dart';
import '../../../../core/shared/presentation/widgets/search_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/reader_entity.dart';
import '../../domain/usecases/reader_usecases.dart';
import '../providers/reader_list_controller.dart';
import '../providers/reader_provider.dart';
import '../widgets/reader_list_tile.dart';

class ReaderListPage extends ConsumerWidget {
  const ReaderListPage({super.key});

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, String readerId) async {
    final ThemeData theme = ref.read(activeThemeDataProvider);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 48),
        title: const Text('Remove Reader'),
        content: const Text(
          'Are you sure you want to remove this reader? This action cannot be undone.',
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
      await ref.read(removeReaderUseCaseProvider)(readerId);
      SnackBars.showSuccess('Reader removed successfully');
    } on NoConnectionException catch (e) {
      SnackBars.showError(e.message);
    } catch (e) {
      SnackBars.showError('Removal failed: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ReaderEntity>> readersAsync = ref.watch(readersStreamProvider);

    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Readers'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.primary,
        scrolledUnderElevation: 1,
      ),
      body: readersAsync.when(
        data: (_) {
          final ReaderListState state = ref.watch(readerListControllerProvider);
          final List<ReaderEntity> readers = state.displayedReaders;

          if (readers.isEmpty && state.searchQuery.isEmpty) {
            return const ListEmptyState(
              icon: Icons.person_search_rounded,
              title: 'No Readers Yet',
              subtitle: 'Tap the button below to add your first reader.',
            );
          }

          return Column(
            children: <Widget>[
              SearchField(
                hintText: 'Search readers by name, email, phone...',
                onChanged: (String query) =>
                    ref.read(readerListControllerProvider.notifier).setSearchQuery(query),
              ),
              if (readers.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No readers match your search.',
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
                          itemCount: readers.length,
                          itemBuilder: (BuildContext context, int index) {
                            final ReaderEntity reader = readers[index];
                            return ReaderListTile(
                              reader: reader,
                              onTap: () => context.go('/readers/${reader.id}'),
                              onEdit: () => context.push('/readers/add', extra: reader),
                              onRemove: () => _handleRemove(context, ref, reader.id),
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
                          itemCount: readers.length,
                          itemBuilder: (BuildContext context, int index) {
                            final ReaderEntity reader = readers[index];
                            return ReaderListTile(
                              reader: reader,
                              onTap: () => context.go('/readers/${reader.id}'),
                              onEdit: () => context.push('/readers/add', extra: reader),
                              onRemove: () => _handleRemove(context, ref, reader.id),
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
        onPressed: () => context.go('/readers/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Reader'),
      ),
    );
  }
}
