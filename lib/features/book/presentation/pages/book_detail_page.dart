import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/detail_widgets.dart';
import '../../../../core/shared/presentation/widgets/info_dialogs.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../../reader/domain/entities/reader_entity.dart';
import '../../../reader/presentation/providers/reader_provider.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../../work/domain/entities/work_entity.dart';
import '../../../work/presentation/providers/work_provider.dart';
import '../../../work/presentation/widgets/work_list_tile.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/book_usecases.dart';
import '../providers/book_provider.dart';

class BookDetailPage extends ConsumerWidget {
  const BookDetailPage({super.key, required this.bookId});
  final String bookId;

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, String bookId) async {
    final ThemeData theme = ref.read(activeThemeDataProvider);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 48),
        title: const Text('Remove Book'),
        content: const Text(
          'Are you sure you want to remove this book? This action cannot be undone.',
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
      await ref.read(removeBookUseCaseProvider)(bookId);
      SnackBars.showSuccess('Book removed successfully');
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
    final AsyncValue<BookEntity?> bookAsync = ref.watch(bookProvider(bookId));
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return bookAsync.when(
      data: (BookEntity? book) {
        if (book == null) {
          return const Scaffold(body: Center(child: Text('Book not found')));
        }

        final AsyncValue<List<WorkEntity>> worksAsync = ref.watch(worksStreamProvider);
        final List<WorkEntity> bookWorks =
            (worksAsync.value ?? <WorkEntity>[])
                .where((WorkEntity w) => book.workIds.contains(w.id))
                .toList()
              ..sort(
                (WorkEntity a, WorkEntity b) =>
                    a.title.toLowerCase().compareTo(b.title.toLowerCase()),
              );

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar.large(
                title: Text(book.title),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded),
                    onPressed: () => context.push('/books/add', extra: book),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded),
                    onPressed: () => _handleRemove(context, ref, book.id),
                    tooltip: 'Remove',
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 16),
                    Hero(
                      tag: 'book_${book.id}',
                      child: Container(
                        width: 280,
                        height: 280 / Images.bookAspectRatio,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Images.getAvatarBackgroundColor(theme),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          image: book.cover != null && book.cover!.isNotEmpty
                              ? DecorationImage(
                                  image: Images.getImageProvider(book.cover),
                                  fit: BoxFit.contain,
                                )
                              : null,
                        ),
                        child: book.cover == null || book.cover!.isEmpty
                            ? Icon(
                                Icons.book_rounded,
                                color: Images.getAvatarIconColor(theme),
                                size: 100,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    DetailSection(
                      title: 'INFORMATION',
                      children: <Widget>[
                        DetailTile(
                          label: 'Authors',
                          value: book.authorIds.isEmpty
                              ? 'No Authors'
                              : book.authorIds
                                    .map(
                                      (String id) =>
                                          ref.watch(authorProvider(id)).value?.name ?? 'Loading...',
                                    )
                                    .join(', '),
                          icon: Icons.person_rounded,
                          onInfo: book.authorIds.length == 1
                              ? () => EntityQuickInfoDialog.show(context, book.authorIds.first, 'author')
                              : null,
                        ),
                        if (book.isTranslation)
                          DetailTile(
                            label: 'Translators',
                            value: book.translatorIds.isEmpty
                                ? 'No Translators'
                                : book.translatorIds
                                      .map(
                                        (String id) =>
                                            ref.watch(translatorProvider(id)).value?.name ??
                                            'Loading...',
                                      )
                                      .join(', '),
                            icon: Icons.translate_rounded,
                            onInfo: book.translatorIds.length == 1
                                ? () => EntityQuickInfoDialog.show(context, book.translatorIds.first, 'translator')
                                : null,
                          ),
                        if (book.originalTitle != null && book.originalTitle!.isNotEmpty)
                          DetailTile(
                            label: 'Original Title',
                            value: book.originalTitle!,
                            icon: Icons.title_rounded,
                          ),
                        if (book.publisherId != null)
                          DetailTile(
                            label: 'Publisher',
                            value: ref
                                .watch(publisherProvider(book.publisherId!))
                                .when(
                                  data: (PublisherEntity? p) => p?.name ?? 'Unknown Publisher',
                                  loading: () => 'Loading...',
                                  error: (_, _) => 'Error',
                                ),
                            icon: Icons.business_rounded,
                            onInfo: () => EntityQuickInfoDialog.show(
                              context,
                              book.publisherId!,
                              'publisher',
                            ),
                          ),
                        if (book.readerId != null)
                          DetailTile(
                            label: 'Reader',
                            value: ref
                                .watch(readerProvider(book.readerId!))
                                .when(
                                  data: (ReaderEntity? r) => r?.name ?? 'Unknown Reader',
                                  loading: () => 'Loading...',
                                  error: (_, _) => 'Error',
                                ),
                            icon: Icons.chrome_reader_mode_rounded,
                            onInfo: () => EntityQuickInfoDialog.show(
                              context,
                              book.readerId!,
                              'reader',
                            ),
                          ),
                        if (book.isbn != null && book.isbn!.isNotEmpty)
                          DetailTile(label: 'ISBN', value: book.isbn!, icon: Icons.qr_code_rounded),
                        if (book.noOfPages != null)
                          DetailTile(
                            label: 'Pages',
                            value: book.noOfPages.toString(),
                            icon: Icons.auto_stories_rounded,
                          ),
                        if (book.publishedDate != null)
                          DetailTile(
                            label: 'Published',
                            value: DateFormat('MMM d, yyyy').format(book.publishedDate!),
                            icon: Icons.event_available_rounded,
                          ),
                        DetailTile(
                          label: 'Status',
                          value:
                              '${book.collectionStatus?.clientValue ?? 'Unknown'} • ${book.readingStatus?.clientValue ?? 'Unknown'}',
                          icon: Icons.bookmark_rounded,
                        ),
                      ],
                    ),
                    if (book.sequenceVolumeIds.isNotEmpty)
                      DetailSection(
                        title: 'SEQUENCES',
                        children: book.sequenceVolumeIds.map((String id) {
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
                            onInfo: () => EntityQuickInfoDialog.show(
                              context,
                              volume.sequenceId,
                              'sequence',
                            ),
                          );
                        }).toList(),
                      ),
                    DetailSection(
                      title: 'WORKS (${bookWorks.length})',
                      showDivider: book.notes != null && book.notes!.isNotEmpty,
                      children: bookWorks
                          .map(
                            (WorkEntity work) => WorkListTile(
                              work: work,
                              onInfo: () => EntityQuickInfoDialog.show(context, work.id, 'work'),
                              onEdit: () => context.push('/works/add', extra: work),
                              onRemove: () {},
                            ),
                          )
                          .toList(),
                    ),
                    if (book.notes != null && book.notes!.isNotEmpty)
                      DetailSection(
                        title: 'NOTES',
                        showDivider: false,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: Text(
                              book.notes!,
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
                          value: DetailTile.formatDate(book.createdDate),
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(book.lastUpdated),
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
