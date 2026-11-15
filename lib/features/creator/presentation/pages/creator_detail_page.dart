import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/pages/image_viewer_page.dart';
import '../../../../core/shared/presentation/utils/dialogs.dart';
import '../../../../core/shared/presentation/utils/external_launcher.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/detail_section.dart';
import '../../../../core/shared/presentation/widgets/detail_tile.dart';
import '../../../../core/shared/presentation/widgets/entity_selection_dialog.dart';
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
import '../../domain/entities/creator_entity.dart';
import '../providers/creator_list_controller.dart';
import '../providers/creator_provider.dart';
import '../widgets/creator_role_selection_dialog.dart';

class CreatorDetailPage extends ConsumerWidget {
  const CreatorDetailPage({super.key, required this.creatorId});
  final String creatorId;

  Future<void> _showAddBookDialog(BuildContext context, WidgetRef ref, CreatorEntity creator) async {
    final List<BookEntity>? allBooks = ref.read(booksStreamProvider).value;
    if (allBooks == null || allBooks.isEmpty) {
      SnackBars.showError('No books available to select.');
      return;
    }

    final BookEntity? selectedBook = await EntitySelectionDialog.showSingle<BookEntity>(
      context: context,
      title: 'Select Book',
      items: allBooks,
      itemLabel: (BookEntity b) => b.title,
      itemKey: (BookEntity b) => b.id,
      icon: FontAwesomeIcons.book,
      sortComparator: (BookEntity a, BookEntity b) {
        final bool aHasNoAuthor = a.authorIds.isEmpty && a.translatorIds.isEmpty;
        final bool bHasNoAuthor = b.authorIds.isEmpty && b.translatorIds.isEmpty;
        if (aHasNoAuthor && !bHasNoAuthor) {
          return -1;
        }
        if (!aHasNoAuthor && bHasNoAuthor) {
          return 1;
        }
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      },
    );

    if (selectedBook == null || !context.mounted) {
      return;
    }

    final bool isAlreadyTranslator = creator.translatedBookIds.contains(selectedBook.id) ||
        selectedBook.translatorIds.contains(creator.id);

    final bool? isTranslator = await CreatorRoleSelectionDialog.show(
      context,
      itemTitle: selectedBook.title,
      initialIsTranslator: isAlreadyTranslator,
    );

    if (isTranslator == null) {
      return;
    }

    try {
      final List<String> updatedAuthorIds = List<String>.from(selectedBook.authorIds);
      final List<String> updatedTranslatorIds = List<String>.from(selectedBook.translatorIds);

      if (isTranslator) {
        updatedAuthorIds.remove(creator.id);
        if (!updatedTranslatorIds.contains(creator.id)) {
          updatedTranslatorIds.add(creator.id);
        }
      } else {
        updatedTranslatorIds.remove(creator.id);
        if (!updatedAuthorIds.contains(creator.id)) {
          updatedAuthorIds.add(creator.id);
        }
      }

      await ref.read(creatorListControllerProvider.notifier).editBook(
        selectedBook.copyWith(
          authorIds: updatedAuthorIds,
          translatorIds: updatedTranslatorIds,
          isTranslation: isTranslator || updatedTranslatorIds.isNotEmpty || selectedBook.isTranslation,
        ),
      );

      SnackBars.showSuccess('"${selectedBook.title}" added to ${creator.name} as ${isTranslator ? 'Translator' : 'Author'}');
    } catch (e) {
      SnackBars.showError('Failed to update creator book: $e');
    }
  }

  Future<void> _showAddWorkDialog(BuildContext context, WidgetRef ref, CreatorEntity creator) async {
    final List<WorkEntity>? allWorks = ref.read(worksStreamProvider).value;
    if (allWorks == null || allWorks.isEmpty) {
      SnackBars.showError('No works available to select.');
      return;
    }

    final WorkEntity? selectedWork = await EntitySelectionDialog.showSingle<WorkEntity>(
      context: context,
      title: 'Select Work',
      items: allWorks,
      itemLabel: (WorkEntity w) => w.title,
      itemKey: (WorkEntity w) => w.id,
      icon: FontAwesomeIcons.bookOpen,
      sortComparator: (WorkEntity a, WorkEntity b) {
        final bool aHasNoAuthor = a.authorIds.isEmpty && a.translatorIds.isEmpty;
        final bool bHasNoAuthor = b.authorIds.isEmpty && b.translatorIds.isEmpty;
        if (aHasNoAuthor && !bHasNoAuthor) {
          return -1;
        }
        if (!aHasNoAuthor && bHasNoAuthor) {
          return 1;
        }
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      },
    );

    if (selectedWork == null || !context.mounted) {
      return;
    }

    final bool isAlreadyTranslator = creator.translatedWorkIds.contains(selectedWork.id) ||
        selectedWork.translatorIds.contains(creator.id);

    final bool? isTranslator = await CreatorRoleSelectionDialog.show(
      context,
      itemTitle: selectedWork.title,
      initialIsTranslator: isAlreadyTranslator,
    );

    if (isTranslator == null) {
      return;
    }

    try {
      final List<String> updatedAuthorIds = List<String>.from(selectedWork.authorIds);
      final List<String> updatedTranslatorIds = List<String>.from(selectedWork.translatorIds);

      if (isTranslator) {
        updatedAuthorIds.remove(creator.id);
        if (!updatedTranslatorIds.contains(creator.id)) {
          updatedTranslatorIds.add(creator.id);
        }
      } else {
        updatedTranslatorIds.remove(creator.id);
        if (!updatedAuthorIds.contains(creator.id)) {
          updatedAuthorIds.add(creator.id);
        }
      }

      await ref.read(creatorListControllerProvider.notifier).editWork(
        selectedWork.copyWith(
          authorIds: updatedAuthorIds,
          translatorIds: updatedTranslatorIds,
          isTranslation: isTranslator || updatedTranslatorIds.isNotEmpty || selectedWork.isTranslation,
        ),
      );

      SnackBars.showSuccess('"${selectedWork.title}" added to ${creator.name} as ${isTranslator ? 'Translator' : 'Author'}');
    } catch (e) {
      SnackBars.showError('Failed to update creator work: $e');
    }
  }

  Future<void> _handleRemoveBook(
    BuildContext context,
    WidgetRef ref,
    CreatorEntity creator,
    BookEntity book,
  ) async {
    final bool confirmed = await AppDialogs.showDestructiveDialog(
      context,
      title: 'Remove Book',
      content: 'Are you sure you want to remove "${book.title}" from ${creator.name}?',
      confirmLabel: 'Remove',
    );
    if (!confirmed) {
      return;
    }

    try {
      final List<String> updatedAuthorIds = book.authorIds.where((String id) => id != creator.id).toList();
      final List<String> updatedTranslatorIds = book.translatorIds.where((String id) => id != creator.id).toList();
      await ref.read(creatorListControllerProvider.notifier).editBook(
        book.copyWith(
          authorIds: updatedAuthorIds,
          translatorIds: updatedTranslatorIds,
        ),
      );
      SnackBars.showSuccess('Removed "${book.title}" from ${creator.name}');
    } catch (e) {
      SnackBars.showError('Failed to remove book: $e');
    }
  }

  Future<void> _handleRemoveWork(
    BuildContext context,
    WidgetRef ref,
    CreatorEntity creator,
    WorkEntity work,
  ) async {
    final bool confirmed = await AppDialogs.showDestructiveDialog(
      context,
      title: 'Remove Work',
      content: 'Are you sure you want to remove "${work.title}" from ${creator.name}?',
      confirmLabel: 'Remove',
    );
    if (!confirmed) {
      return;
    }

    try {
      final List<String> updatedAuthorIds = work.authorIds.where((String id) => id != creator.id).toList();
      final List<String> updatedTranslatorIds = work.translatorIds.where((String id) => id != creator.id).toList();
      await ref.read(creatorListControllerProvider.notifier).editWork(
        work.copyWith(
          authorIds: updatedAuthorIds,
          translatorIds: updatedTranslatorIds,
        ),
      );
      SnackBars.showSuccess('Removed "${work.title}" from ${creator.name}');
    } catch (e) {
      SnackBars.showError('Failed to remove work: $e');
    }
  }

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, CreatorEntity creator) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Creator',
      entityName: creator.name,
      onConfirm: () async {
        await ref.read(creatorListControllerProvider.notifier).removeCreator(creator.id);
        if (context.mounted) {
          context.pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CreatorEntity?> creatorAsync = ref.watch(creatorProvider(creatorId));
    final ThemeData theme = ref.watch(activeThemeDataProvider);

    return creatorAsync.when(
      data: (CreatorEntity? creator) {
        if (creator == null) {
          return const Scaffold(
            body: ListEmptyState(
              icon: FontAwesomeIcons.user,
              title: 'Creator Not Found',
              subtitle: 'This creator may have been removed.',
            ),
          );
        }

        final AsyncValue<List<BookEntity>> booksAsync = ref.watch(booksStreamProvider);
        final AsyncValue<List<WorkEntity>> worksAsync = ref.watch(worksStreamProvider);

        final List<BookEntity> allBooks = booksAsync.value ?? <BookEntity>[];
        final List<WorkEntity> allWorks = worksAsync.value ?? <WorkEntity>[];

        final List<BookEntity> authoredBooks = allBooks
            .where((BookEntity b) =>
                creator.authoredBookIds.contains(b.id) || b.authorIds.contains(creator.id))
            .toList()
          ..sort((BookEntity a, BookEntity b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

        final List<BookEntity> translatedBooks = allBooks
            .where((BookEntity b) =>
                creator.translatedBookIds.contains(b.id) || b.translatorIds.contains(creator.id))
            .toList()
          ..sort((BookEntity a, BookEntity b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

        final List<WorkEntity> authoredWorks = allWorks
            .where((WorkEntity w) =>
                creator.authoredWorkIds.contains(w.id) || w.authorIds.contains(creator.id))
            .toList()
          ..sort((WorkEntity a, WorkEntity b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

        final List<WorkEntity> translatedWorks = allWorks
            .where((WorkEntity w) =>
                creator.translatedWorkIds.contains(w.id) || w.translatorIds.contains(creator.id))
            .toList()
          ..sort((WorkEntity a, WorkEntity b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

        final int totalBooksCount = authoredBooks.length + translatedBooks.length;
        final int totalWorksCount = authoredWorks.length + translatedWorks.length;

        final String bookSectionTitle = totalBooksCount == 1 ? 'BOOK ($totalBooksCount)' : 'BOOKS ($totalBooksCount)';
        final String workSectionTitle = totalWorksCount == 1 ? 'WORK ($totalWorksCount)' : 'WORKS ($totalWorksCount)';

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar.large(
                title: Text(
                  creator.name,
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
                      await context.push('/creators/upsert', extra: creator);
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.trash),
                    onPressed: () => _handleRemove(context, ref, creator),
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
                        tag: 'creator_${creator.id}',
                        child: creator.image != null && creator.image!.isNotEmpty
                            ? Tooltip(
                                message: 'View maximized picture',
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => ImageViewerPage.open(
                                      context,
                                      imageSource: creator.image!,
                                      title: creator.name,
                                      heroTag: 'creator_${creator.id}',
                                    ),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxHeight: 240,
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
                                            image: Images.getImageProvider(creator.image),
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                width: 240,
                                height: 240,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Images.getAvatarBackgroundColor(theme),
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.user,
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
                        if (creator.otherName != null && creator.otherName!.isNotEmpty)
                          DetailTile(
                            label: 'Other Name',
                            value: creator.otherName!,
                            leadingIcon: FontAwesomeIcons.idBadge,
                          ),
                        DetailTile(
                          label: 'Books Count',
                          value: '$totalBooksCount ${totalBooksCount == 1 ? 'book' : 'books'}',
                          leadingIcon: FontAwesomeIcons.book,
                        ),
                        DetailTile(
                          label: 'Works Count',
                          value: '$totalWorksCount ${totalWorksCount == 1 ? 'work' : 'works'}',
                          leadingIcon: FontAwesomeIcons.fileLines,
                        ),
                        if (creator.website != null && creator.website!.isNotEmpty)
                          DetailTile(
                            label: 'Website',
                            value: creator.website!,
                            leadingIcon: FontAwesomeIcons.globe,
                            trailingIcon: FontAwesomeIcons.arrowUpRightFromSquare,
                            onTap: () => ExternalLauncher.launchBrowser(creator.website!),
                          ),
                        if (creator.facebook != null && creator.facebook!.isNotEmpty)
                          DetailTile(
                            label: 'Facebook',
                            value: creator.facebook!,
                            leadingIcon: FontAwesomeIcons.facebook,
                            trailingIcon: FontAwesomeIcons.arrowUpRightFromSquare,
                            onTap: () => ExternalLauncher.launchBrowser(creator.facebook!),
                          ),
                        DetailTile(
                          label: 'Created',
                          value: DetailTile.formatDate(creator.createdDate),
                          leadingIcon: FontAwesomeIcons.calendar,
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(creator.lastUpdated),
                          leadingIcon: FontAwesomeIcons.clockRotateLeft,
                        ),
                      ],
                    ),
                    DetailSection(
                      title: bookSectionTitle,
                      actions: <Widget>[
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.bookMedical, size: 20),
                          tooltip: 'Add Book',
                          onPressed: () => _showAddBookDialog(context, ref, creator),
                        ),
                      ],
                      children: <Widget>[
                        if (authoredBooks.isNotEmpty) ...<Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'As Author',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ...authoredBooks.map(
                            (BookEntity book) => BookListTile(
                              book: book,
                              onTap: () => BookQuickInfoDialog.show(context, book.id),
                              onRemove: () => _handleRemoveBook(context, ref, creator, book),
                            ),
                          ),
                        ],
                        if (translatedBooks.isNotEmpty) ...<Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(24, authoredBooks.isNotEmpty ? 16 : 8, 24, 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'As Translator',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ...translatedBooks.map(
                            (BookEntity book) => BookListTile(
                              book: book,
                              onTap: () => BookQuickInfoDialog.show(context, book.id),
                              onRemove: () => _handleRemoveBook(context, ref, creator, book),
                            ),
                          ),
                        ],
                      ],
                    ),
                    DetailSection(
                      title: workSectionTitle,
                      showDivider: false,
                      actions: <Widget>[
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.fileMedical, size: 20),
                          tooltip: 'Add Work',
                          onPressed: () => _showAddWorkDialog(context, ref, creator),
                        ),
                      ],
                      children: <Widget>[
                        if (authoredWorks.isNotEmpty) ...<Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'As Author',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ...authoredWorks.map(
                            (WorkEntity work) => WorkListTile(
                              work: work,
                              onTap: () => WorkQuickInfoDialog.show(context, work.id),
                              onRemove: () => _handleRemoveWork(context, ref, creator, work),
                            ),
                          ),
                        ],
                        if (translatedWorks.isNotEmpty) ...<Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(24, authoredWorks.isNotEmpty ? 16 : 8, 24, 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'As Translator',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ...translatedWorks.map(
                            (WorkEntity work) => WorkListTile(
                              work: work,
                              onTap: () => WorkQuickInfoDialog.show(context, work.id),
                              onRemove: () => _handleRemoveWork(context, ref, creator, work),
                            ),
                          ),
                        ],
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
