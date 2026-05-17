import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/dialogs.dart';
import '../../../../core/shared/presentation/widgets/list_empty_state.dart';
import '../../../../core/shared/presentation/widgets/list_error_state.dart';
import '../../../../core/shared/presentation/widgets/list_loading_state.dart';
import '../../../../core/shared/presentation/widgets/search_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/reader_entity.dart';
import '../../domain/usecases/reader_usecases.dart';
import '../providers/reader_list_controller.dart';
import '../providers/reader_provider.dart';
import '../widgets/reader_list_tile.dart';

class ReaderListPage extends ConsumerStatefulWidget {
  const ReaderListPage({super.key});

  @override
  ConsumerState<ReaderListPage> createState() => _ReaderListPageState();
}

class _ReaderListPageState extends ConsumerState<ReaderListPage> {
  bool _isExtended = true;

  Future<void> _handleRemove(String readerId, String readerName) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Reader',
      entityName: readerName,
      onConfirm: () => ref.read(removeReaderUseCaseProvider)(readerId),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              icon: Icons.face_rounded,
              title: 'No Readers Yet',
              subtitle: 'Tap the button below to add your first reader.',
            );
          }

          return NotificationListener<UserScrollNotification>(
            onNotification: (UserScrollNotification notification) {
              if (notification.direction == ScrollDirection.reverse) {
                if (_isExtended) {
                  setState(() => _isExtended = false);
                }
              } else if (notification.direction == ScrollDirection.forward) {
                if (!_isExtended) {
                  setState(() => _isExtended = true);
                }
              }

              return true;
            },
            child: Column(
              children: <Widget>[
                SearchField(
                  hintText: 'Search',
                  onChanged: (String query) =>
                      ref.read(readerListControllerProvider.notifier).setSearchQuery(query),
                ),
                if (readers.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No readers match your search.',
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
                            itemCount: readers.length,
                            itemBuilder: (BuildContext context, int index) {
                              final ReaderEntity reader = readers[index];

                              return ReaderListTile(
                                reader: reader,
                                onTap: () => context.go('/readers/${reader.id}'),
                                onEdit: () => context.push('/readers/upsert', extra: reader),
                                onRemove: () => _handleRemove(reader.id, reader.name),
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
                            itemCount: readers.length,
                            itemBuilder: (BuildContext context, int index) {
                              final ReaderEntity reader = readers[index];

                              return ReaderListTile(
                                reader: reader,
                                onTap: () => context.go('/readers/${reader.id}'),
                                onEdit: () => context.push('/readers/upsert', extra: reader),
                                onRemove: () => _handleRemove(reader.id, reader.name),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const ListLoadingState(),
        error: (Object err, StackTrace stack) => ListErrorState(error: err),
      ),
      floatingActionButton: FloatingActionButton.extended(
        isExtended: _isExtended,
        backgroundColor: Buttons.getPrimaryActionBackgroundColor(theme),
        foregroundColor: Buttons.getPrimaryActionForegroundColor(theme),
        onPressed: () => context.go('/readers/upsert'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Reader'),
      ),
    );
  }
}
