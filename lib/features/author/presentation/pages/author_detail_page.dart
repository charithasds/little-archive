import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/utils/dialogs.dart';
import '../../../../core/shared/presentation/utils/external_launcher.dart';
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
import '../../domain/entities/author_entity.dart';
import '../../domain/usecases/author_usecases.dart';
import '../providers/author_provider.dart';

class AuthorDetailPage extends ConsumerWidget {
  const AuthorDetailPage({super.key, required this.authorId});
  final String authorId;

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, AuthorEntity author) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Author',
      entityName: author.name,
      onConfirm: () async {
        await ref.read(removeAuthorUseCaseProvider)(author.id);
        if (context.mounted) {
          context.pop();
        }
      },
    );
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
              icon: FontAwesomeIcons.user,
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
                    icon: const FaIcon(FontAwesomeIcons.penToSquare),
                    onPressed: () async {
                      await context.push('/authors/upsert', extra: author);
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.trash),
                    onPressed: () => _handleRemove(context, ref, author),
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
                          alignment: Alignment.center,
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
                              ? FaIcon(
                                  FontAwesomeIcons.user,
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
                            leadingIcon: FontAwesomeIcons.idBadge,
                          ),
                        DetailTile(
                          label: 'Books Count',
                          value: '${authorBooks.length} books',
                          leadingIcon: FontAwesomeIcons.book,
                        ),
                        DetailTile(
                          label: 'Works Count',
                          value: '${authorWorks.length} works',
                          leadingIcon: FontAwesomeIcons.fileLines,
                        ),
                        if (author.website != null && author.website!.isNotEmpty)
                          DetailTile(
                            label: 'Website',
                            value: author.website!,
                            leadingIcon: FontAwesomeIcons.globe,
                            trailingIcon: FontAwesomeIcons.arrowUpRightFromSquare,
                            onTap: () => ExternalLauncher.launchBrowser(author.website!),
                          ),
                        if (author.facebook != null && author.facebook!.isNotEmpty)
                          DetailTile(
                            label: 'Facebook',
                            value: author.facebook!,
                            leadingIcon: FontAwesomeIcons.facebook,
                            trailingIcon: FontAwesomeIcons.arrowUpRightFromSquare,
                            onTap: () => ExternalLauncher.launchBrowser(author.facebook!),
                          ),
                        DetailTile(
                          label: 'Created',
                          value: DetailTile.formatDate(author.createdDate),
                          leadingIcon: FontAwesomeIcons.calendar,
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(author.lastUpdated),
                          leadingIcon: FontAwesomeIcons.clockRotateLeft,
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
                              onTap: () => BookQuickInfoDialog.show(context, book.id),
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
                              onTap: () => WorkQuickInfoDialog.show(context, work.id),
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
