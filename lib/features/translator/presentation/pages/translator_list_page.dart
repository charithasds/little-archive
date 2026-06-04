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
import '../../domain/entities/translator_entity.dart';
import '../../domain/usecases/translator_usecases.dart';
import '../providers/translator_list_controller.dart';
import '../providers/translator_provider.dart';
import '../widgets/translator_list_tile.dart';

class TranslatorListPage extends ConsumerStatefulWidget {
  const TranslatorListPage({super.key});

  @override
  ConsumerState<TranslatorListPage> createState() => _TranslatorListPageState();
}

class _TranslatorListPageState extends ConsumerState<TranslatorListPage> {
  bool _isExtended = true;

  Future<void> _handleRemove(String translatorId, String translatorName) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Translator',
      entityName: translatorName,
      onConfirm: () async {
        await ref.read(removeTranslatorUseCaseProvider)(translatorId);
        ref.invalidate(translatorCountProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<TranslatorEntity>> translatorsAsync = ref.watch(
      translatorsStreamProvider,
    );
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Translators'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.primary,
        scrolledUnderElevation: 1,
      ),
      body: translatorsAsync.when(
        data: (_) {
          final TranslatorListState state = ref.watch(translatorListControllerProvider);
          final List<TranslatorEntity> translators = state.displayedTranslators;

          if (translators.isEmpty && state.searchQuery.isEmpty) {
            return const ListEmptyState(
              icon: FontAwesomeIcons.language,
              title: 'No Translators Yet',
              subtitle: 'Tap the button below to add your first translator.',
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
                      ref.read(translatorListControllerProvider.notifier).setSearchQuery(query),
                ),
                if (translators.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No translators match your search.',
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
                            itemCount: translators.length,
                            itemBuilder: (BuildContext context, int index) {
                              final TranslatorEntity translator = translators[index];

                              return TranslatorListTile(
                                translator: translator,
                                onTap: () => context.goNamed(RouteConstants.translatorDetail, pathParameters: <String, String>{'id': translator.id}),
                                onEdit: () =>
                                    context.pushNamed(RouteConstants.upsertTranslator, extra: translator),
                                onRemove: () => _handleRemove(translator.id, translator.name),
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
                            itemCount: translators.length,
                            itemBuilder: (BuildContext context, int index) {
                              final TranslatorEntity translator = translators[index];

                              return TranslatorListTile(
                                translator: translator,
                                onTap: () => context.goNamed(RouteConstants.translatorDetail, pathParameters: <String, String>{'id': translator.id}),
                                onEdit: () =>
                                    context.pushNamed(RouteConstants.upsertTranslator, extra: translator),
                                onRemove: () => _handleRemove(translator.id, translator.name),
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
        onPressed: () => context.pushNamed(RouteConstants.upsertTranslator),
        icon: const FaIcon(FontAwesomeIcons.plus),
        label: const Text('Add Translator'),
      ),
    );
  }
}
