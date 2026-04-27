import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/detail_widgets.dart';
import '../../../../core/shared/presentation/widgets/info_dialogs.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../work/domain/entities/work_entity.dart';
import '../../../work/presentation/providers/work_provider.dart';
import '../../domain/entities/sequence_entity.dart';
import '../../domain/entities/sequence_volume_entity.dart';
import '../../domain/usecases/sequence_usecases.dart';
import '../providers/sequence_provider.dart';

class SequenceDetailPage extends ConsumerWidget {
  const SequenceDetailPage({super.key, required this.sequenceId});
  final String sequenceId;

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, String sequenceId) async {
    final ThemeData theme = ref.read(activeThemeDataProvider);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 48),
        title: const Text('Remove Sequence'),
        content: const Text(
          'Are you sure you want to remove this sequence? This action cannot be undone.',
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
      await ref.read(removeSequenceUseCaseProvider)(sequenceId);
      SnackBars.showSuccess('Sequence removed successfully');
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
    final AsyncValue<SequenceEntity?> sequenceAsync = ref.watch(sequenceProvider(sequenceId));
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return sequenceAsync.when(
      data: (SequenceEntity? sequence) {
        if (sequence == null) {
          return const Scaffold(body: Center(child: Text('Sequence not found')));
        }

        final AsyncValue<List<SequenceVolumeEntity>> volumesAsync = ref.watch(
          sequenceVolumesStreamProvider(sequenceId),
        );
        final List<SequenceVolumeEntity> volumes = volumesAsync.value ?? <SequenceVolumeEntity>[];
        // Sort volumes by volume number numerically if possible, else alphabetically
        final List<SequenceVolumeEntity> sortedVolumes = <SequenceVolumeEntity>[...volumes]
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
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded),
                    onPressed: () => context.push('/sequences/add', extra: sequence),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded),
                    onPressed: () => _handleRemove(context, ref, sequence.id),
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
                      Icons.layers_rounded,
                      size: 200,
                      color: colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    DetailSection(
                      title: 'INFORMATION',
                      children: <Widget>[
                        if (sequence.otherName != null && sequence.otherName!.isNotEmpty)
                          DetailTile(
                            label: 'Other Name',
                            value: sequence.otherName!,
                            icon: Icons.badge_rounded,
                          ),
                        DetailTile(
                          label: 'Total Volumes',
                          value: sequence.sequenceVolumeIds.length.toString(),
                          icon: Icons.numbers_rounded,
                        ),
                      ],
                    ),
                    DetailSection(
                      title: 'VOLUMES',
                      children: sortedVolumes.map((SequenceVolumeEntity volume) {
                        String title = 'Not Collected';
                        IconData icon = Icons.help_outline_rounded;
                        VoidCallback? onTap;

                        if (volume.bookId != null && volume.bookId!.isNotEmpty) {
                          final AsyncValue<BookEntity?> bookAsync = ref.watch(bookProvider(volume.bookId!));
                          title = bookAsync.when(
                            data: (BookEntity? book) => book?.title ?? 'Unknown Book',
                            loading: () => 'Loading...',
                            error: (_, _) => 'Error loading book',
                          );
                          icon = Icons.book_rounded;
                          onTap = () => EntityQuickInfoDialog.show(context, volume.bookId!, 'book');
                        } else if (volume.workId != null && volume.workId!.isNotEmpty) {
                          final AsyncValue<WorkEntity?> workAsync = ref.watch(workProvider(volume.workId!));
                          title = workAsync.when(
                            data: (WorkEntity? work) => work?.title ?? 'Unknown Work',
                            loading: () => 'Loading...',
                            error: (_, _) => 'Error loading work',
                          );
                          icon = Icons.article_rounded;
                          onTap = () => EntityQuickInfoDialog.show(context, volume.workId!, 'work');
                        }

                        final String volumeLabel =
                            volume.volume.isEmpty ? 'Unknown Volume' : 'Volume ${volume.volume}';

                        return DetailTile(
                          label: volumeLabel,
                          value: title,
                          icon: icon,
                          onInfo: onTap,
                        );
                      }).toList(),
                    ),
                    if (sequence.notes != null && sequence.notes!.isNotEmpty)
                      DetailSection(
                        title: 'NOTES',
                        showDivider: false,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: Text(
                              sequence.notes!,
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
                          value: DetailTile.formatDate(sequence.createdDate),
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(sequence.lastUpdated),
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
