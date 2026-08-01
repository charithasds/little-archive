import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/routes/route_constants.dart';

import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/dialogs.dart';
import '../../../../core/shared/presentation/widgets/list_empty_state.dart';
import '../../../../core/shared/presentation/widgets/list_error_state.dart';
import '../../../../core/shared/presentation/widgets/list_loading_state.dart';
import '../../../../core/shared/presentation/widgets/search_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/creator_entity.dart';
import '../../domain/usecases/creator_usecases.dart';
import '../providers/creator_list_controller.dart';
import '../providers/creator_provider.dart';
import '../widgets/creator_list_tile.dart';

class CreatorListPage extends ConsumerStatefulWidget {
  const CreatorListPage({super.key});

  @override
  ConsumerState<CreatorListPage> createState() => _CreatorListPageState();
}

class _CreatorListPageState extends ConsumerState<CreatorListPage> {
  bool _isExtended = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(creatorListControllerProvider.notifier).setSearchQuery('');
  }

  Future<void> _navigateTo(Future<void> Function() navigation) async {
    await navigation();
    if (mounted) {
      _clearSearch();
    }
  }

  Future<void> _handleRemove(String creatorId, String creatorName) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Creator',
      entityName: creatorName,
      onConfirm: () async {
        await ref.read(removeCreatorUseCaseProvider)(creatorId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CreatorEntity>> creatorsAsync = ref.watch(creatorsStreamProvider);
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Creators'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.primary,
        scrolledUnderElevation: 1,
      ),
      body: creatorsAsync.when(
        data: (_) {
          final CreatorListState state = ref.watch(creatorListControllerProvider);
          final List<CreatorEntity> creators = state.displayedCreators;

          if (creators.isEmpty && state.searchQuery.isEmpty) {
            return const ListEmptyState(
              icon: FontAwesomeIcons.user,
              title: 'No Creators Yet',
              subtitle: 'Tap the button below to add your first creator.',
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
                  controller: _searchController,
                  hintText: 'Search',
                  onChanged: (String query) =>
                      ref.read(creatorListControllerProvider.notifier).setSearchQuery(query),
                ),

                if (creators.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No creators match your search.',
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
                            itemCount: creators.length,
                            itemBuilder: (BuildContext context, int index) {
                              final CreatorEntity creator = creators[index];

                              return CreatorListTile(
                                creator: creator,
                                onTap: () => _navigateTo(() => context.pushNamed(RouteConstants.creatorDetail, pathParameters: <String, String>{'id': creator.id})),
                                onEdit: () => _navigateTo(() => context.pushNamed(RouteConstants.upsertCreator, extra: creator)),
                                onRemove: () => _handleRemove(creator.id, creator.name),
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
                            itemCount: creators.length,
                            itemBuilder: (BuildContext context, int index) {
                              final CreatorEntity creator = creators[index];

                              return CreatorListTile(
                                creator: creator,
                                onTap: () => _navigateTo(() => context.pushNamed(RouteConstants.creatorDetail, pathParameters: <String, String>{'id': creator.id})),
                                onEdit: () => _navigateTo(() => context.pushNamed(RouteConstants.upsertCreator, extra: creator)),
                                onRemove: () => _handleRemove(creator.id, creator.name),
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
        onPressed: () => _navigateTo(() => context.pushNamed(RouteConstants.upsertCreator)),
        icon: const FaIcon(FontAwesomeIcons.plus),
        label: const Text('Add Creator'),
      ),
    );
  }
}
