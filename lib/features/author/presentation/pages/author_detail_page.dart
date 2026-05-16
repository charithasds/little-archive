import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/external_launcher.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/detail_widgets.dart';
import '../../../../core/shared/presentation/widgets/info_dialogs.dart';
import '../../../../core/shared/presentation/widgets/list_page_states.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../book/presentation/widgets/book_list_tile.dart';
import '../../../work/domain/entities/work_entity.dart';
import '../../../work/presentation/providers/work_provider.dart';
import '../../../work/presentation/widgets/work_list_tile.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/usecases/author_usecases.dart';
import '../providers/author_provider.dart';

class AuthorDetailPage extends ConsumerWidget {
  const AuthorDetailPage({super.key, required this.authorId});
  final String authorId;

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, String authorId) async {
    final ThemeData theme = ref.read(activeThemeDataProvider);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 48),
        title: const Text('Remove Author'),
        content: const Text(
          'Are you sure you want to remove this author? This action cannot be undone.',
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
      await ref.read(removeAuthorUseCaseProvider)(authorId);
      SnackBars.showSuccess('Author removed successfully');
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
    final AsyncValue<AuthorEntity?> authorAsync = ref.watch(authorProvider(authorId));
    final ThemeData theme = ref.watch(activeThemeDataProvider);

    return authorAsync.when(
      data: (AuthorEntity? author) {
        if (author == null) {
          return const Scaffold(
            body: ListEmptyState(
              icon: Icons.person_rounded,
              title: 'Author Not Found',
              subtitle: 'This author may have been removed.',
            ),
          );
        }

        final AsyncValue<List<BookEntity>> booksAsync = ref.watch(booksStreamProvider);
        final AsyncValue<List<WorkEntity>> worksAsync = ref.watch(worksStreamProvider);

        final List<BookEntity> authorBooks =
            (booksAsync.value ?? <BookEntity>[])
                .where((BookEntity b) => author.bookIds.contains(b.id))
                .toList()
              ..sort(
                (BookEntity a, BookEntity b) =>
                    a.title.toLowerCase().compareTo(b.title.toLowerCase()),
              );

        final List<WorkEntity> authorWorks =
            (worksAsync.value ?? <WorkEntity>[])
                .where((WorkEntity w) => author.workIds.contains(w.id))
                .toList()
              ..sort(
                (WorkEntity a, WorkEntity b) =>
                    a.title.toLowerCase().compareTo(b.title.toLowerCase()),
              );

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar.large(
                title: Text(author.name),
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
                surfaceTintColor: theme.colorScheme.primary,
                scrolledUnderElevation: 1,
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded),
                    onPressed: () async {
                      await context.push('/authors/add', extra: author);
                      ref.invalidate(authorProvider(authorId));
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _handleRemove(context, ref, author.id),
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
                        tag: 'author_${author.id}',
                        child: Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Images.getAvatarBackgroundColor(theme),
                            image: author.image != null && author.image!.isNotEmpty
                                ? DecorationImage(
                                    image: Images.getImageProvider(author.image),
                                    fit: BoxFit.contain,
                                  )
                                : null,
                          ),
                          child: author.image == null || author.image!.isEmpty
                              ? Icon(
                                  Icons.person_rounded,
                                  color: Images.getAvatarIconColor(theme),
                                  size: 120,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    DetailSection(
                      title: 'INFORMATION',
                      children: <Widget>[
                        if (author.otherName != null && author.otherName!.isNotEmpty)
                          DetailTile(
                            label: 'Other Name',
                            value: author.otherName!,
                            icon: Icons.badge_rounded,
                          ),
                        DetailTile(
                          label: 'Books Count',
                          value: '${authorBooks.length} books',
                          icon: Icons.book_rounded,
                        ),
                        DetailTile(
                          label: 'Works Count',
                          value: '${authorWorks.length} works',
                          icon: Icons.article_rounded,
                        ),
                        if (author.website != null && author.website!.isNotEmpty)
                          DetailTile(
                            label: 'Website',
                            value: author.website!,
                            icon: Icons.language_rounded,
                            trailingIcon: Icons.open_in_new_rounded,
                            onTap: () => ExternalLauncher.launchBrowser(author.website!),
                          ),
                        if (author.facebook != null && author.facebook!.isNotEmpty)
                          DetailTile(
                            label: 'Facebook',
                            value: author.facebook!,
                            icon: Icons.facebook_rounded,
                            trailingIcon: Icons.open_in_new_rounded,
                            onTap: () => ExternalLauncher.launchBrowser(author.facebook!),
                          ),
                        DetailTile(
                          label: 'Created',
                          value: DetailTile.formatDate(author.createdDate),
                          icon: Icons.calendar_today_rounded,
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(author.lastUpdated),
                          icon: Icons.update_rounded,
                        ),
                      ],
                    ),
                    DetailSection(
                      title: 'BOOKS (${authorBooks.length})',
                      showDivider: authorWorks.isNotEmpty,
                      children: authorBooks
                          .map(
                            (BookEntity book) => BookListTile(
                              book: book,
                              onInfo: () => EntityQuickInfoDialog.show(context, book.id, 'book'),
                            ),
                          )
                          .toList(),
                    ),
                    DetailSection(
                      title: 'WORKS (${authorWorks.length})',
                      showDivider: false,
                      children: authorWorks
                          .map(
                            (WorkEntity work) => WorkListTile(
                              work: work,
                              onInfo: () => EntityQuickInfoDialog.show(context, work.id, 'work'),
                            ),
                          )
                          .toList(),
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
