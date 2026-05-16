import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/list_page_states.dart';
import '../../../../core/shared/presentation/widgets/search_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/publisher_entity.dart';
import '../../domain/usecases/publisher_usecases.dart';
import '../providers/publisher_list_controller.dart';
import '../providers/publisher_provider.dart';
import '../widgets/publisher_list_tile.dart';

class PublisherListPage extends ConsumerWidget {
  const PublisherListPage({super.key});

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, String publisherId) async {
    final ThemeData theme = ref.read(activeThemeDataProvider);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 48),
        title: const Text('Remove Publisher'),
        content: const Text(
          'Are you sure you want to remove this publisher? This action cannot be undone.',
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
      await ref.read(removePublisherUseCaseProvider)(publisherId);
      SnackBars.showSuccess('Publisher removed successfully');
    } on NoConnectionException catch (e) {
      SnackBars.showError(e.message);
    } catch (e) {
      SnackBars.showError('Removal failed: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PublisherEntity>> publishersAsync = ref.watch(publishersStreamProvider);

    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Publishers'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.primary,
        scrolledUnderElevation: 1,
      ),
      body: publishersAsync.when(
        data: (_) {
          final PublisherListState state = ref.watch(publisherListControllerProvider);
          final List<PublisherEntity> publishers = state.displayedPublishers;

          if (publishers.isEmpty && state.searchQuery.isEmpty) {
            return const ListEmptyState(
              icon: Icons.business_rounded,
              title: 'No Publishers Yet',
              subtitle: 'Tap the button below to add your first publisher.',
            );
          }

          return Column(
            children: <Widget>[
              SearchField(
                hintText: 'Search publishers by name, website, email...',
                onChanged: (String query) =>
                    ref.read(publisherListControllerProvider.notifier).setSearchQuery(query),
              ),
              if (publishers.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No publishers match your search.',
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
                          itemCount: publishers.length,
                          itemBuilder: (BuildContext context, int index) {
                            final PublisherEntity publisher = publishers[index];
                            return PublisherListTile(
                              publisher: publisher,
                              onTap: () => context.go('/publishers/${publisher.id}'),
                              onEdit: () => context.push('/publishers/add', extra: publisher),
                              onRemove: () => _handleRemove(context, ref, publisher.id),
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
                          itemCount: publishers.length,
                          itemBuilder: (BuildContext context, int index) {
                            final PublisherEntity publisher = publishers[index];
                            return PublisherListTile(
                              publisher: publisher,
                              onTap: () => context.go('/publishers/${publisher.id}'),
                              onEdit: () => context.push('/publishers/add', extra: publisher),
                              onRemove: () => _handleRemove(context, ref, publisher.id),
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
        onPressed: () => context.go('/publishers/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Publisher'),
      ),
    );
  }
}
