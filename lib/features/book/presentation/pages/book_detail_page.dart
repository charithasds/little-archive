import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/shared/presentation/utils/dialogs.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/shared/presentation/utils/validators.dart';
import '../../../../core/shared/presentation/widgets/detail_section.dart';
import '../../../../core/shared/presentation/widgets/detail_tile.dart';
import '../../../../core/shared/presentation/widgets/list_empty_state.dart';
import '../../../../core/shared/presentation/widgets/list_error_state.dart';
import '../../../../core/shared/presentation/widgets/list_loading_state.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../author/domain/entities/author_entity.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../author/presentation/widgets/author_list_tile.dart';
import '../../../author/presentation/widgets/author_quick_info_dialog.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../../publisher/presentation/widgets/publisher_list_tile.dart';
import '../../../publisher/presentation/widgets/publisher_quick_info_dialog.dart';
import '../../../reader/domain/entities/reader_entity.dart';
import '../../../reader/presentation/providers/reader_provider.dart';
import '../../../reader/presentation/widgets/reader_list_tile.dart';
import '../../../reader/presentation/widgets/reader_quick_info_dialog.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../sequence/presentation/widgets/sequence_quick_info_dialog.dart';
import '../../../sequence/presentation/widgets/sequence_volume_list_tile.dart';
import '../../../translator/domain/entities/translator_entity.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../../translator/presentation/widgets/translator_list_tile.dart';
import '../../../translator/presentation/widgets/translator_quick_info_dialog.dart';
import '../../../work/domain/entities/work_entity.dart';
import '../../../work/presentation/providers/work_provider.dart';
import '../../../work/presentation/widgets/work_list_tile.dart';
import '../../../work/presentation/widgets/work_quick_info_dialog.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/book_usecases.dart';
import '../providers/book_provider.dart';

class BookDetailPage extends ConsumerWidget {
  const BookDetailPage({super.key, required this.bookId});
  final String bookId;

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, BookEntity book) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Book',
      entityName: book.title,
      onConfirm: () async {
        await ref.read(removeBookUseCaseProvider)(book.id);
        ref.invalidate(bookCountProvider);
        if (context.mounted) {
          context.pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<BookEntity?> bookAsync = ref.watch(bookProvider(bookId));
    final ThemeData theme = ref.watch(activeThemeDataProvider);

    return bookAsync.when(
      data: (BookEntity? book) {
        if (book == null) {
          return const Scaffold(
            body: ListEmptyState(
              icon: FontAwesomeIcons.book,
              title: 'Book Not Found',
              subtitle: 'This book may have been removed.',
            ),
          );
        }

        final List<AuthorEntity> authors = book.authorIds
            .map((String id) => ref.watch(authorProvider(id)).value)
            .whereType<AuthorEntity>()
            .toList();
        final List<TranslatorEntity> translators = book.translatorIds
            .map((String id) => ref.watch(translatorProvider(id)).value)
            .whereType<TranslatorEntity>()
            .toList();
        final AsyncValue<List<WorkEntity>> worksAsync = ref.watch(worksStreamProvider);
        final List<WorkEntity> bookWorks =
            (worksAsync.value ?? <WorkEntity>[])
                .where((WorkEntity w) => book.workIds.contains(w.id))
                .toList()
              ..sort(
                (WorkEntity a, WorkEntity b) =>
                    a.title.toLowerCase().compareTo(b.title.toLowerCase()),
              );
        final AsyncValue<PublisherEntity?> publisherAsync = book.publisherId != null
            ? ref.watch(publisherProvider(book.publisherId!))
            : const AsyncValue<PublisherEntity?>.data(null);
        final AsyncValue<ReaderEntity?> readerAsync = book.readerId != null
            ? ref.watch(readerProvider(book.readerId!))
            : const AsyncValue<ReaderEntity?>.data(null);

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar.large(
                title: Text(book.title),
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
                surfaceTintColor: theme.colorScheme.primary,
                scrolledUnderElevation: 1,
                actions: <Widget>[
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.penToSquare),
                    onPressed: () async {
                      await context.push('/books/upsert', extra: book);
                      ref.invalidate(bookProvider(bookId));
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.trash),
                    onPressed: () => _handleRemove(context, ref, book),
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
                        tag: 'book_${book.id}',
                        child: Container(
                          width: 240,
                          height: 240 / Images.bookAspectRatio,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Images.getAvatarBackgroundColor(theme),
                            image: book.cover != null && book.cover!.isNotEmpty
                                ? DecorationImage(
                                    image: Images.getImageProvider(book.cover),
                                    fit: BoxFit.contain,
                                  )
                                : null,
                          ),
                          child: book.cover == null || book.cover!.isEmpty
                              ? FaIcon(
                                  FontAwesomeIcons.book,
                                  color: Images.getAvatarIconColor(theme),
                                  size: 120,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (authors.isNotEmpty)
                      DetailSection(
                        title: 'AUTHORS',
                        children: authors.map(
                          (AuthorEntity author) => AuthorListTile(
                            author: author,
                            onTap: () => AuthorQuickInfoDialog.show(context, author.id),
                          ),
                        ).toList(),
                      ),
                    if (translators.isNotEmpty)
                      DetailSection(
                        title: 'TRANSLATORS',
                        children: translators.map(
                          (TranslatorEntity translator) => TranslatorListTile(
                            translator: translator,
                            onTap: () => TranslatorQuickInfoDialog.show(context, translator.id),
                          ),
                        ).toList(),
                      ),
                    if (bookWorks.isNotEmpty)
                      DetailSection(
                        title: 'WORKS',
                        children: bookWorks
                            .map(
                              (WorkEntity work) => WorkListTile(
                                work: work,
                                onTap: () => WorkQuickInfoDialog.show(context, work.id),
                              ),
                            )
                            .toList(),
                      ),
                    if (book.sequenceVolumeIds.isNotEmpty)
                      DetailSection(
                        title: 'SEQUENCE',
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
                    if (book.publisherId != null)
                      DetailSection(
                        title: 'PUBLISHER',
                        children: <Widget>[
                          publisherAsync.when(
                            data: (PublisherEntity? publisher) {
                              if (publisher == null) {
                                return const SizedBox.shrink();
                              }

                              return PublisherListTile(
                                publisher: publisher,
                                onTap: () => PublisherQuickInfoDialog.show(context, publisher.id),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, _) => const Text('Error loading publisher'),
                          ),
                        ],
                      ),
                    if (book.readerId != null)
                      DetailSection(
                        title: 'READER',
                        children: <Widget>[
                          readerAsync.when(
                            data: (ReaderEntity? reader) {
                              if (reader == null) {
                                return const SizedBox.shrink();
                              }

                              return ReaderListTile(
                                reader: reader,
                                onTap: () => ReaderQuickInfoDialog.show(context, reader.id),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, _) => const Text('Error loading reader'),
                          ),
                        ],
                      ),
                    DetailSection(
                      title: 'INFORMATION',
                      showDivider: false,
                      children: <Widget>[
                        DetailTile(
                          label: 'To Be Translated',
                          value: book.toBeTranslated ? 'Yes' : 'No',
                          leadingIcon: FontAwesomeIcons.language,
                        ),
                        DetailTile(
                          label: 'Compilation Type',
                          value: book.compilationType.clientValue,
                          leadingIcon: FontAwesomeIcons.book,
                        ),
                        if (book.language != null)
                          DetailTile(
                            label: 'Language',
                            value: book.language!.clientValue,
                            leadingIcon: FontAwesomeIcons.globe,
                          ),
                        if (book.genre != null)
                          DetailTile(
                            label: 'Genre',
                            value: book.genre!.clientValue,
                            leadingIcon: FontAwesomeIcons.tags,
                          ),
                        if (book.isbn != null && book.isbn!.isNotEmpty)
                          DetailTile(
                            label: 'ISBN',
                            value: Validators.formatIsbn(book.isbn!),
                            leadingIcon: FontAwesomeIcons.qrcode,
                          ),
                        if (book.publishedDate != null)
                          DetailTile(
                            label: 'Published Date',
                            value: DateFormat('MMM d, yyyy').format(book.publishedDate!),
                            leadingIcon: FontAwesomeIcons.earthAmericas,
                          ),
                        if (book.noOfPages != null)
                          DetailTile(
                            label: 'Number of Pages',
                            value: book.noOfPages.toString(),
                            leadingIcon: FontAwesomeIcons.hashtag,
                          ),
                        if (book.originalTitle != null && book.originalTitle!.isNotEmpty)
                          DetailTile(
                            label: 'Original Title',
                            value: book.originalTitle!,
                            leadingIcon: FontAwesomeIcons.heading,
                          ),
                        if (book.isTranslation && book.originalLanguage != null)
                          DetailTile(
                            label: 'Original Language',
                            value: book.originalLanguage!.clientValue,
                            leadingIcon: FontAwesomeIcons.language,
                          ),
                        DetailTile(
                          label: 'Collection Status',
                          value: book.collectionStatus.clientValue,
                          leadingIcon: FontAwesomeIcons.boxesStacked,
                        ),
                        if (book.collectedDate != null)
                          DetailTile(
                            label: 'Collected Date',
                            value: DateFormat('MMM d, yyyy').format(book.collectedDate!),
                            leadingIcon: FontAwesomeIcons.boxArchive,
                          ),
                        if (book.lendedDate != null)
                          DetailTile(
                            label: 'Lended Date',
                            value: DateFormat('MMM d, yyyy').format(book.lendedDate!),
                            leadingIcon: FontAwesomeIcons.handshake,
                          ),
                        if (book.dueDate != null)
                          DetailTile(
                            label: 'Due Date',
                            value: DateFormat('MMM d, yyyy').format(book.dueDate!),
                            leadingIcon: FontAwesomeIcons.calendarDays,
                          ),
                        DetailTile(
                          label: 'Reading Status',
                          value: book.readingStatus.clientValue,
                          leadingIcon: FontAwesomeIcons.bookOpen,
                        ),
                        if (book.pausedPage != null)
                          DetailTile(
                            label: 'Paused Page',
                            value: book.pausedPage!.toString(),
                            leadingIcon: FontAwesomeIcons.bookmark,
                          ),
                        if (book.completedDate != null)
                          DetailTile(
                            label: 'Completed Date',
                            value: DateFormat('MMM d, yyyy').format(book.completedDate!),
                            leadingIcon: FontAwesomeIcons.circleCheck,
                          ),
                        if (book.notes != null && book.notes!.isNotEmpty)
                          DetailTile(
                            label: 'Notes',
                            value: book.notes!,
                            leadingIcon: FontAwesomeIcons.noteSticky,
                          ),
                        DetailTile(
                          label: 'Created',
                          value: DetailTile.formatDate(book.createdDate),
                          leadingIcon: FontAwesomeIcons.calendar,
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(book.lastUpdated),
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
