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
import '../../domain/entities/sequence_entity.dart';
import '../../domain/usecases/sequence_usecases.dart';
import '../providers/sequence_list_controller.dart';
import '../providers/sequence_provider.dart';
import '../widgets/sequence_list_tile.dart';

class SequenceListPage extends ConsumerStatefulWidget {
  const SequenceListPage({super.key});

  @override
  ConsumerState<SequenceListPage> createState() => _SequenceListPageState();
}

class _SequenceListPageState extends ConsumerState<SequenceListPage> {
  bool _isExtended = true;

  Future<void> _handleRemove(String sequenceId, String sequenceName) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Sequence',
      entityName: sequenceName,
      onConfirm: () async {
        await ref.read(removeSequenceUseCaseProvider)(sequenceId);
        ref.invalidate(sequenceCountProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              icon: FontAwesomeIcons.layerGroup,
              title: 'No Sequences Yet',
              subtitle: 'Tap the button below to add your first sequence.',
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
                                onTap: () => context.goNamed(RouteConstants.sequenceDetail, pathParameters: <String, String>{'id': sequence.id}),
                                onEdit: () => context.pushNamed(RouteConstants.upsertSequence, extra: sequence),
                                onRemove: () => _handleRemove(sequence.id, sequence.name),
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
                            itemCount: sequences.length,
                            itemBuilder: (BuildContext context, int index) {
                              final SequenceEntity sequence = sequences[index];

                              return SequenceListTile(
                                sequence: sequence,
                                onTap: () => context.goNamed(RouteConstants.sequenceDetail, pathParameters: <String, String>{'id': sequence.id}),
                                onEdit: () => context.pushNamed(RouteConstants.upsertSequence, extra: sequence),
                                onRemove: () => _handleRemove(sequence.id, sequence.name),
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
        onPressed: () => context.pushNamed(RouteConstants.upsertSequence),
        icon: const FaIcon(FontAwesomeIcons.plus),
        label: const Text('Add Sequence'),
      ),
    );
  }
}
