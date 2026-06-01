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
import '../../domain/entities/work_entity.dart';
import '../../domain/usecases/work_usecases.dart';
import '../providers/work_list_controller.dart';
import '../providers/work_provider.dart';
import '../widgets/work_list_tile.dart';

class WorkListPage extends ConsumerStatefulWidget {
  const WorkListPage({super.key});

  @override
  ConsumerState<WorkListPage> createState() => _WorkListPageState();
}

class _WorkListPageState extends ConsumerState<WorkListPage> {
  bool _isExtended = true;

  Future<void> _handleRemove(String workId, String workTitle) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Work',
      entityName: workTitle,
      onConfirm: () async {
        await ref.read(removeWorkUseCaseProvider)(workId);
        ref.invalidate(workCountProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              icon: FontAwesomeIcons.fileLines,
              title: 'No Works Yet',
              subtitle: 'Tap the button below to add your first work.',
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
                                onEdit: () => context.push('/works/upsert', extra: work),
                                onRemove: () => _handleRemove(work.id, work.title),
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
                                onEdit: () => context.push('/works/upsert', extra: work),
                                onRemove: () => _handleRemove(work.id, work.title),
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
        onPressed: () => context.go('/works/upsert'),
        icon: const FaIcon(FontAwesomeIcons.plus),
        label: const Text('Add Work'),
      ),
    );
  }
}
