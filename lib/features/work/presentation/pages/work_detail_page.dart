import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/detail_widgets.dart';
import '../../../../core/shared/presentation/widgets/info_dialogs.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
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
          return const Scaffold(body: Center(child: Text('Work not found')));
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar.large(
                title: Text(work.title),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded),
                    onPressed: () => context.push('/works/add', extra: work),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded),
                    onPressed: () => _handleRemove(context, ref, work.id),
                    tooltip: 'Remove',
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 16),
                    Icon(
                      Icons.article_rounded,
                      size: 200,
                      color: colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    DetailSection(
                      title: 'INFORMATION',
                      children: <Widget>[
                        DetailTile(
                          label: 'Authors',
                          value: work.authorIds.isEmpty
                              ? 'No Authors'
                              : work.authorIds
                                    .map(
                                      (String id) =>
                                          ref.watch(authorProvider(id)).value?.name ?? 'Loading...',
                                    )
                                    .join(', '),
                          icon: Icons.person_rounded,
                          onInfo: work.authorIds.length == 1
                              ? () => EntityQuickInfoDialog.show(
                                  context,
                                  work.authorIds.first,
                                  'author',
                                )
                              : null,
                        ),
                        if (work.isTranslation)
                          DetailTile(
                            label: 'Translators',
                            value: work.translatorIds.isEmpty
                                ? 'No Translators'
                                : work.translatorIds
                                      .map(
                                        (String id) =>
                                            ref.watch(translatorProvider(id)).value?.name ??
                                            'Loading...',
                                      )
                                      .join(', '),
                            icon: Icons.translate_rounded,
                            onInfo: work.translatorIds.length == 1
                                ? () => EntityQuickInfoDialog.show(
                                    context,
                                    work.translatorIds.first,
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
                        if (work.language != null)
                          DetailTile(
                            label: 'Language',
                            value: work.language!.clientValue,
                            icon: Icons.language_rounded,
                          ),
                      ],
                    ),
                    if (work.bookId != null)
                      DetailSection(
                        title: 'BOOK',
                        children: <Widget>[
                          DetailTile(
                            label: 'Collected in',
                            value: ref
                                .watch(bookProvider(work.bookId!))
                                .when(
                                  data: (BookEntity? book) => book?.title ?? 'Unknown Book',
                                  loading: () => 'Loading...',
                                  error: (_, _) => 'Error',
                                ),
                            icon: Icons.book_rounded,
                            onInfo: () => EntityQuickInfoDialog.show(context, work.bookId!, 'book'),
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
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(work.lastUpdated),
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
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (Object err, StackTrace stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
