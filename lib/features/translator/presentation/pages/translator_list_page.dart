import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/list_page_states.dart';
import '../../../../core/shared/presentation/widgets/search_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/translator_entity.dart';
import '../../domain/usecases/translator_usecases.dart';
import '../providers/translator_list_controller.dart';
import '../providers/translator_provider.dart';
import '../widgets/translator_list_tile.dart';

class TranslatorListPage extends ConsumerWidget {
  const TranslatorListPage({super.key});

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, String translatorId) async {
    final ThemeData theme = ref.read(activeThemeDataProvider);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 48),
        title: const Text('Remove Translator'),
        content: const Text(
          'Are you sure you want to remove this translator? This action cannot be undone.',
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
      await ref.read(removeTranslatorUseCaseProvider)(translatorId);
      SnackBars.showSuccess('Translator removed successfully');
    } on NoConnectionException catch (e) {
      SnackBars.showError(e.message);
    } catch (e) {
      SnackBars.showError('Removal failed: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              icon: Icons.translate_rounded,
              title: 'No Translators Yet',
              subtitle: 'Tap the button below to add your first translator.',
            );
          }

          return Column(
            children: <Widget>[
              SearchField(
                hintText: 'Search translators by name, website...',
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
                              onTap: () => context.go('/translators/${translator.id}'),
                              onEdit: () => context.push('/translators/add', extra: translator),
                              onRemove: () => _handleRemove(context, ref, translator.id),
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
                          itemCount: translators.length,
                          itemBuilder: (BuildContext context, int index) {
                            final TranslatorEntity translator = translators[index];
                            return TranslatorListTile(
                              translator: translator,
                              onTap: () => context.go('/translators/${translator.id}'),
                              onEdit: () => context.push('/translators/add', extra: translator),
                              onRemove: () => _handleRemove(context, ref, translator.id),
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
        onPressed: () => context.go('/translators/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Translator'),
      ),
    );
  }
}
