import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/detail_widgets.dart';
import '../../../../core/shared/presentation/widgets/info_dialogs.dart';
import '../../../../core/shared/presentation/widgets/list_page_states.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../book/presentation/widgets/book_list_tile.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/usecases/work_usecases.dart';
import '../providers/work_provider.dart';

class WorkDetailPage extends ConsumerWidget {
  const WorkDetailPage({super.key, required this.workId});
  final String workId;

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, String workId) async {
    final ThemeData theme = ref.read(activeThemeDataProvider);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 48),
        title: const Text('Remove Work'),
        content: const Text(
          'Are you sure you want to remove this work? This action cannot be undone.',
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
      await ref.read(removeWorkUseCaseProvider)(workId);
      SnackBars.showSuccess('Work removed successfully');
      if (context.mounted) {
        context.pop();
      }
    } on NoConnectionException catch (e) {
      SnackBars.showError(e.message);
    } catch (e) {
      SnackBars.showError('Removal failed: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<WorkEntity?> workAsync = ref.watch(workProvider(workId));
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return workAsync.when(
      data: (WorkEntity? work) {
        if (work == null) {
          return const Scaffold(
            body: ListEmptyState(
              icon: Icons.article_rounded,
              title: 'Work Not Found',
              subtitle: 'This work may have been removed.',
            ),
          );
        }

        final AsyncValue<BookEntity?> bookAsync = work.bookId != null
            ? ref.watch(bookProvider(work.bookId!))
            : const AsyncValue<BookEntity?>.data(null);

        final List<String> authorsToDisplay = work.authorIds;
        final List<String> translatorsToDisplay = work.translatorIds;

        final Language? languageToDisplay = work.language;
        final OriginalLanguage? originalLanguageToDisplay = work.originalLanguage;
        final bool isTranslationToDisplay = work.isTranslation;

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar.large(
                title: Text(work.title),
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
                surfaceTintColor: theme.colorScheme.primary,
                scrolledUnderElevation: 1,
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded),
                    onPressed: () async {
                      await context.push('/works/add', extra: work);
                      ref.invalidate(workProvider(workId));
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _handleRemove(context, ref, work.id),
                    tooltip: 'Remove',
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 16),
                    Center(
                      child: work.bookId != null
                          ? bookAsync.when(
                              data: (BookEntity? book) {
                                final String? cover = book?.cover;
                                return Material(
                                  type: MaterialType.transparency,
                                  child: Container(
                                    width: 200,
                                    height: 200 / Images.bookAspectRatio,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Images.getAvatarBackgroundColor(theme),
                                      image: cover != null && cover.isNotEmpty
                                          ? DecorationImage(
                                              image: Images.getImageProvider(cover),
                                              fit: BoxFit.contain,
                                            )
                                          : null,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: cover == null || cover.isEmpty
                                        ? Icon(
                                            Icons.article_rounded,
                                            size: 52,
                                            color: Images.getAvatarIconColor(theme),
                                          )
                                        : null,
                                  ),
                                );
                              },
                              loading: () => const SizedBox(
                                height: 200 / Images.bookAspectRatio,
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              error: (_, _) => Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Icon(
                                  Icons.article_rounded,
                                  size: 52,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Icon(
                                Icons.article_rounded,
                                size: 52,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                    DetailSection(
                      title: 'INFORMATION',
                      children: <Widget>[
                        DetailTile(
                          label: 'Authors',
                          value: authorsToDisplay.isEmpty
                              ? 'No Authors'
                              : authorsToDisplay
                                    .map((String id) => ref.watch(authorProvider(id)).value?.name)
                                    .where((String? n) => n != null)
                                    .join(', '),
                          icon: Icons.person_rounded,
                          onInfo: authorsToDisplay.length == 1
                              ? () => EntityQuickInfoDialog.show(
                                  context,
                                  authorsToDisplay.first,
                                  'author',
                                )
                              : null,
                        ),
                        if (isTranslationToDisplay)
                          DetailTile(
                            label: 'Translators',
                            value: translatorsToDisplay.isEmpty
                                ? 'No Translators'
                                : translatorsToDisplay
                                      .map(
                                        (String id) =>
                                            ref.watch(translatorProvider(id)).value?.name,
                                      )
                                      .where((String? n) => n != null)
                                      .join(', '),
                            icon: Icons.translate_rounded,
                            onInfo: translatorsToDisplay.length == 1
                                ? () => EntityQuickInfoDialog.show(
                                    context,
                                    translatorsToDisplay.first,
                                    'translator',
                                  )
                                : null,
                          ),
                        if (work.originalTitle != null && work.originalTitle!.isNotEmpty)
                          DetailTile(
                            label: 'Original Title',
                            value: work.originalTitle!,
                            icon: Icons.title_rounded,
                          ),
                        DetailTile(
                          label: 'Category',
                          value: work.contentCategory.clientValue,
                          icon: Icons.category_rounded,
                        ),
                        if (work.genre != null)
                          DetailTile(
                            label: 'Genre',
                            value: work.genre!.clientValue,
                            icon: Icons.style_rounded,
                          ),
                        if (languageToDisplay != null)
                          DetailTile(
                            label: 'Language',
                            value: languageToDisplay.clientValue,
                            icon: Icons.language_rounded,
                          ),
                        if (isTranslationToDisplay && originalLanguageToDisplay != null)
                          DetailTile(
                            label: 'Original Language',
                            value: originalLanguageToDisplay.clientValue,
                            icon: Icons.translate_rounded,
                          ),
                      ],
                    ),
                    if (work.bookId != null)
                      DetailSection(
                        title: 'BOOK',
                        children: <Widget>[
                          bookAsync.when(
                            data: (BookEntity? book) {
                              if (book == null) {
                                return const SizedBox.shrink();
                              }
                              return BookListTile(
                                book: book,
                                onInfo: () => EntityQuickInfoDialog.show(context, book.id, 'book'),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, _) => const Text('Error loading book'),
                          ),
                        ],
                      ),
                    if (work.sequenceVolumeIds.isNotEmpty)
                      DetailSection(
                        title: 'SEQUENCES',
                        children: work.sequenceVolumeIds.map((String id) {
                          final SequenceVolumeEntity? volume = ref
                              .watch(sequenceVolumeProvider(id))
                              .value;
                          if (volume == null) {
                            return const SizedBox.shrink();
                          }
                          final SequenceEntity? sequence = ref
                              .watch(sequenceProvider(volume.sequenceId))
                              .value;
                          final String sequenceName = sequence?.name ?? 'Loading...';
                          return DetailTile(
                            label: sequenceName,
                            value: 'Volume ${volume.volume}',
                            icon: Icons.layers_rounded,
                            onInfo: () =>
                                EntityQuickInfoDialog.show(context, volume.sequenceId, 'sequence'),
                          );
                        }).toList(),
                      ),
                    if (work.notes != null && work.notes!.isNotEmpty)
                      DetailSection(
                        title: 'NOTES',
                        showDivider: false,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                            child: Text(
                              work.notes!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    DetailSection(
                      title: 'METADATA',
                      showDivider: false,
                      children: <Widget>[
                        DetailTile(
                          label: 'Created',
                          value: DetailTile.formatDate(work.createdDate),
                          icon: Icons.calendar_today_rounded,
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(work.lastUpdated),
                          icon: Icons.update_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: ListLoadingState()),
      error: (Object err, StackTrace stack) => Scaffold(body: ListErrorState(error: err)),
    );
  }
}
