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
import '../../../work/domain/entities/work_entity.dart';
import '../../../work/presentation/providers/work_provider.dart';
import '../../../work/presentation/widgets/work_list_tile.dart';
import '../../../work/presentation/widgets/work_quick_info_dialog.dart';
import '../../domain/entities/sequence_entity.dart';
import '../../domain/entities/sequence_volume_entity.dart';
import '../../domain/usecases/sequence_usecases.dart';
import '../providers/sequence_provider.dart';

class SequenceDetailPage extends ConsumerWidget {
  const SequenceDetailPage({super.key, required this.sequenceId});
  final String sequenceId;

  Future<void> _showAddBookVolumeSheet(
    BuildContext context,
    WidgetRef ref,
    SequenceEntity sequence,
  ) async {
    await context.push(
      '/books/upsert',
      extra: <String, dynamic>{
        'preselectedSequence': sequence,
      },
    );
  }

  Future<void> _showAddWorkVolumeSheet(
    BuildContext context,
    WidgetRef ref,
    SequenceEntity sequence,
  ) async {
    await context.push(
      '/works/upsert',
      extra: <String, dynamic>{
        'preselectedSequence': sequence,
      },
    );
  }

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, SequenceEntity sequence) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Sequence',
      entityName: sequence.name,
      onConfirm: () async {
        await ref.read(removeSequenceUseCaseProvider)(sequence.id);
        if (context.mounted) {
          context.pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<SequenceEntity?> sequenceAsync = ref.watch(sequenceProvider(sequenceId));
    final ThemeData theme = ref.watch(activeThemeDataProvider);

    return sequenceAsync.when(
      data: (SequenceEntity? sequence) {
        if (sequence == null) {
          return const Scaffold(
            body: ListEmptyState(
              icon: FontAwesomeIcons.layerGroup,
              title: 'Sequence Not Found',
              subtitle: 'This sequence may have been removed.',
            ),
          );
        }

        final AsyncValue<List<SequenceVolumeEntity>> volumesAsync = ref.watch(
          sequenceVolumesStreamProvider(sequenceId),
        );
        final AsyncValue<List<BookEntity>> booksAsync = ref.watch(booksStreamProvider);
        final AsyncValue<List<WorkEntity>> worksAsync = ref.watch(worksStreamProvider);

        if (volumesAsync.hasError || booksAsync.hasError || worksAsync.hasError) {
          final Object error = volumesAsync.error ?? booksAsync.error ?? worksAsync.error ?? 'Unknown error';
          return Scaffold(body: ListErrorState(error: error));
        }

        if (volumesAsync.value == null || booksAsync.value == null || worksAsync.value == null) {
          return const Scaffold(body: ListLoadingState());
        }

        final List<BookEntity> books = booksAsync.value!;
        final List<WorkEntity> works = worksAsync.value!;

        final List<SequenceVolumeEntity> sequenceVolumes = volumesAsync.value!.toList()
          ..sort((SequenceVolumeEntity a, SequenceVolumeEntity b) {
            final double? aVal = double.tryParse(a.volume);
            final double? bVal = double.tryParse(b.volume);

            if (aVal != null && bVal != null) {
              return aVal.compareTo(bVal);
            }

            return a.volume.compareTo(b.volume);
          });

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar.large(
                title: Text(sequence.name),
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
                surfaceTintColor: theme.colorScheme.primary,
                scrolledUnderElevation: 1,
                actions: <Widget>[
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.penToSquare),
                    onPressed: () async {
                      await context.push('/sequences/upsert', extra: sequence);
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.trash),
                    onPressed: () => _handleRemove(context, ref, sequence),
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
                        tag: 'sequence_${sequence.id}',
                        child: Container(
                          width: 240,
                          height: 240,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Images.getAvatarBackgroundColor(theme),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.layerGroup,
                            color: Images.getAvatarIconColor(theme),
                            size: 120,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    DetailSection(
                      title: 'INFORMATION',
                      children: <Widget>[
                        DetailTile(
                          label: 'Volumes Count',
                          value: '${sequence.sequenceVolumeIds.length} volumes',
                          leadingIcon: FontAwesomeIcons.listOl,
                        ),
                        if (sequence.notes != null && sequence.notes!.isNotEmpty)
                          DetailTile(
                            label: 'Notes',
                            value: sequence.notes!,
                            leadingIcon: FontAwesomeIcons.noteSticky,
                          ),
                        DetailTile(
                          label: 'Created',
                          value: DetailTile.formatDate(sequence.createdDate),
                          leadingIcon: FontAwesomeIcons.calendar,
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(sequence.lastUpdated),
                          leadingIcon: FontAwesomeIcons.clockRotateLeft,
                        ),
                      ],
                    ),
                    DetailSection(
                      title: 'VOLUMES (${sequenceVolumes.length})',
                      showDivider: false,
                      actions: <Widget>[
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.bookMedical, size: 20),
                          tooltip: 'Add Book Volume',
                          onPressed: () => _showAddBookVolumeSheet(context, ref, sequence),
                        ),
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.fileMedical, size: 20),
                          tooltip: 'Add Work Volume',
                          onPressed: () => _showAddWorkVolumeSheet(context, ref, sequence),
                        ),
                      ],
                      children: sequenceVolumes.map((SequenceVolumeEntity volume) {
                        final String volumeLabel = volume.volume.isEmpty
                            ? '??'
                            : 'Volume #${volume.volume}';

                        if (volume.bookId != null && volume.bookId!.isNotEmpty) {
                          final BookEntity? book = books
                              .where((BookEntity b) => b.id == volume.bookId)
                              .firstOrNull;

                          if (book != null) {
                            return BookListTile(
                              book: book.copyWith(title: '$volumeLabel: ${book.title}'),
                              onTap: () => BookQuickInfoDialog.show(context, book.id),
                            );
                          }
                        }

                        if (volume.workId != null && volume.workId!.isNotEmpty) {
                          final WorkEntity? work = works
                              .where((WorkEntity w) => w.id == volume.workId)
                              .firstOrNull;

                          if (work != null) {
                            return WorkListTile(
                              work: work.copyWith(title: '$volumeLabel: ${work.title}'),
                              onTap: () => WorkQuickInfoDialog.show(context, work.id),
                            );
                          }
                        }

                        return const SizedBox.shrink();
                      }).toList(),
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
