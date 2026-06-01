import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/dialogs.dart';
import '../../../../core/shared/presentation/widgets/list_empty_state.dart';
import '../../../../core/shared/presentation/widgets/list_error_state.dart';
import '../../../../core/shared/presentation/widgets/list_loading_state.dart';
import '../../../../core/shared/presentation/widgets/search_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/publisher_entity.dart';
import '../../domain/usecases/publisher_usecases.dart';
import '../providers/publisher_list_controller.dart';
import '../providers/publisher_provider.dart';
import '../widgets/publisher_list_tile.dart';

class PublisherListPage extends ConsumerStatefulWidget {
  const PublisherListPage({super.key});

  @override
  ConsumerState<PublisherListPage> createState() => _PublisherListPageState();
}

class _PublisherListPageState extends ConsumerState<PublisherListPage> {
  bool _isExtended = true;

  Future<void> _handleRemove(String publisherId, String publisherName) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Publisher',
      entityName: publisherName,
      onConfirm: () async {
        await ref.read(removePublisherUseCaseProvider)(publisherId);
        ref.invalidate(publisherCountProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              icon: FontAwesomeIcons.building,
              title: 'No Publishers Yet',
              subtitle: 'Tap the button below to add your first publisher.',
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
                                onEdit: () => context.push('/publishers/upsert', extra: publisher),
                                onRemove: () => _handleRemove(publisher.id, publisher.name),
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
                            itemCount: publishers.length,
                            itemBuilder: (BuildContext context, int index) {
                              final PublisherEntity publisher = publishers[index];

                              return PublisherListTile(
                                publisher: publisher,
                                onTap: () => context.go('/publishers/${publisher.id}'),
                                onEdit: () => context.push('/publishers/upsert', extra: publisher),
                                onRemove: () => _handleRemove(publisher.id, publisher.name),
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
        onPressed: () => context.go('/publishers/upsert'),
        icon: const FaIcon(FontAwesomeIcons.plus),
        label: const Text('Add Publisher'),
      ),
    );
  }
}
