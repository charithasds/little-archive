import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/utils/dialogs.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/shared/presentation/widgets/detail_section.dart';
import '../../../../core/shared/presentation/widgets/detail_tile.dart';
import '../../../../core/shared/presentation/widgets/list_empty_state.dart';
import '../../../../core/shared/presentation/widgets/list_error_state.dart';
import '../../../../core/shared/presentation/widgets/list_loading_state.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../book/presentation/widgets/book_list_tile.dart';
import '../../../book/presentation/widgets/book_quick_info_dialog.dart';
import '../../../creator/domain/entities/creator_entity.dart';
import '../../../creator/presentation/providers/creator_provider.dart';
import '../../../creator/presentation/widgets/creator_list_tile.dart';
import '../../../creator/presentation/widgets/creator_quick_info_dialog.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../sequence/presentation/widgets/sequence_quick_info_dialog.dart';
import '../../../sequence/presentation/widgets/sequence_volume_list_tile.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/usecases/work_usecases.dart';
import '../providers/work_provider.dart';

class WorkDetailPage extends ConsumerWidget {
  const WorkDetailPage({super.key, required this.workId});
  final String workId;

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, WorkEntity work) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Work',
      entityName: work.title,
      onConfirm: () async {
        await ref.read(removeWorkUseCaseProvider)(work.id);
        if (context.mounted) {
          context.pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<WorkEntity?> workAsync = ref.watch(workProvider(workId));
    final ThemeData theme = ref.watch(activeThemeDataProvider);

    return workAsync.when(
      data: (WorkEntity? work) {
        if (work == null) {
          return const Scaffold(
            body: ListEmptyState(
              icon: FontAwesomeIcons.fileLines,
              title: 'Work Not Found',
              subtitle: 'This work may have been removed.',
            ),
          );
        }

        final List<CreatorEntity> authors = work.authorIds
            .map((String id) => ref.watch(creatorProvider(id)).value)
            .whereType<CreatorEntity>()
            .toList();
        final List<CreatorEntity> translators = work.translatorIds
            .map((String id) => ref.watch(creatorProvider(id)).value)
            .whereType<CreatorEntity>()
            .toList();
        final AsyncValue<BookEntity?> bookAsync = work.bookId != null
            ? ref.watch(bookProvider(work.bookId!))
            : const AsyncValue<BookEntity?>.data(null);

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar.large(
                title: Text(
                  work.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
                surfaceTintColor: theme.colorScheme.primary,
                scrolledUnderElevation: 1,
                actions: <Widget>[
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.penToSquare),
                    onPressed: () async {
                      await context.push('/works/upsert', extra: work);
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.trash),
                    onPressed: () => _handleRemove(context, ref, work),
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
                      child: Hero(
                        tag: 'work_${work.id}',
                        child: work.bookId != null
                            ? bookAsync.when(
                                data: (BookEntity? book) {
                                  final String? cover = book?.cover;

                                  return cover != null && cover.isNotEmpty
                                      ? ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxHeight: 320,
                                            maxWidth: 240,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(
                                                color: theme.colorScheme.outlineVariant,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(3),
                                              child: Image(
                                                image: Images.getImageProvider(cover),
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 240,
                                          height: 240 / Images.bookAspectRatio,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Images.getAvatarBackgroundColor(theme),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: theme.colorScheme.outlineVariant,
                                            ),
                                          ),
                                          child: FaIcon(
                                            FontAwesomeIcons.fileLines,
                                            color: Images.getAvatarIconColor(theme),
                                            size: 120,
                                          ),
                                        );
                                },
                                loading: () => Container(
                                  width: 240,
                                  height: 240 / Images.bookAspectRatio,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Images.getAvatarBackgroundColor(theme),
                                  ),
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                error: (_, _) => Container(
                                  width: 240,
                                  height: 240 / Images.bookAspectRatio,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Images.getAvatarBackgroundColor(theme),
                                  ),
                                  child: FaIcon(
                                    FontAwesomeIcons.fileLines,
                                    size: 120,
                                    color: Images.getAvatarIconColor(theme),
                                  ),
                                ),
                              )
                            : Container(
                                width: 240,
                                height: 240 / Images.bookAspectRatio,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Images.getAvatarBackgroundColor(theme),
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.fileLines,
                                  size: 120,
                                  color: Images.getAvatarIconColor(theme),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (authors.isNotEmpty)
                      DetailSection(
                        title: authors.length == 1 ? 'AUTHOR' : 'AUTHORS',
                        children: authors
                            .map(
                              (CreatorEntity author) => CreatorListTile(
                                creator: author,
                                onTap: () => CreatorQuickInfoDialog.show(context, author.id),
                              ),
                            )
                            .toList(),
                      ),
                    if (translators.isNotEmpty)
                      DetailSection(
                        title: translators.length == 1 ? 'TRANSLATOR' : 'TRANSLATORS',
                        children: translators
                            .map(
                              (CreatorEntity translator) => CreatorListTile(
                                creator: translator,
                                onTap: () => CreatorQuickInfoDialog.show(context, translator.id),
                              ),
                            )
                            .toList(),
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
                                onTap: () => BookQuickInfoDialog.show(context, book.id),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, _) => const Text('Error loading book'),
                          ),
                        ],
                      ),
                    if (work.sequenceVolumeIds.isNotEmpty)
                      DetailSection(
                        title: 'SEQUENCE',
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

                          if (sequence == null) {
                            return const SizedBox.shrink();
                          }

                          return SequenceVolumeListTile(
                            volume: volume,
                            sequence: sequence,
                            onTap: () => SequenceQuickInfoDialog.show(context, volume.sequenceId),
                          );
                        }).toList(),
                      ),
                    DetailSection(
                      title: 'INFORMATION',
                      showDivider: false,
                      children: <Widget>[
                        DetailTile(
                          label: 'To Be Translated',
                          value: work.toBeTranslated ? 'Yes' : 'No',
                          leadingIcon: FontAwesomeIcons.language,
                        ),
                        DetailTile(
                          label: 'Content Category',
                          value: work.contentCategory.clientValue,
                          leadingIcon: FontAwesomeIcons.folder,
                        ),
                        if (work.language != null)
                          DetailTile(
                            label: 'Language',
                            value: work.language!.clientValue,
                            leadingIcon: FontAwesomeIcons.globe,
                          ),
                        if (work.genre != null)
                          DetailTile(
                            label: 'Genre',
                            value: work.genre!.clientValue,
                            leadingIcon: FontAwesomeIcons.tags,
                          ),
                        if (work.originalTitle != null && work.originalTitle!.isNotEmpty)
                          DetailTile(
                            label: 'Original Title',
                            value: work.originalTitle!,
                            leadingIcon: FontAwesomeIcons.heading,
                          ),
                        if (work.isTranslation && work.originalLanguage != null)
                          DetailTile(
                            label: 'Original Language',
                            value: work.originalLanguage!.clientValue,
                            leadingIcon: FontAwesomeIcons.language,
                          ),
                        if (work.notes != null && work.notes!.isNotEmpty)
                          DetailTile(
                            label: 'Notes',
                            value: work.notes!,
                            leadingIcon: FontAwesomeIcons.noteSticky,
                          ),
                        DetailTile(
                          label: 'Created',
                          value: DetailTile.formatDate(work.createdDate),
                          leadingIcon: FontAwesomeIcons.calendar,
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(work.lastUpdated),
                          leadingIcon: FontAwesomeIcons.clockRotateLeft,
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
