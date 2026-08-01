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
import '../../domain/entities/creator_entity.dart';
import '../../domain/usecases/creator_usecases.dart';
import '../providers/creator_provider.dart';

class CreatorDetailPage extends ConsumerWidget {
  const CreatorDetailPage({super.key, required this.creatorId});
  final String creatorId;

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, CreatorEntity creator) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Creator',
      entityName: creator.name,
      onConfirm: () async {
        await ref.read(removeCreatorUseCaseProvider)(creator.id);
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
        final List<BookEntity> creatorBooks =
            (booksAsync.value ?? <BookEntity>[])
                .where((BookEntity b) => creator.authoredBookIds.contains(b.id) || creator.translatedBookIds.contains(b.id))
                .toList()
              ..sort(
                (BookEntity a, BookEntity b) =>
                    a.title.toLowerCase().compareTo(b.title.toLowerCase()),
              );
        final List<WorkEntity> creatorWorks =
            (worksAsync.value ?? <WorkEntity>[])
                .where((WorkEntity w) => creator.authoredWorkIds.contains(w.id) || creator.translatedWorkIds.contains(w.id))
                .toList()
              ..sort(
                (WorkEntity a, WorkEntity b) =>
                    a.title.toLowerCase().compareTo(b.title.toLowerCase()),
              );

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
                            ? ConstrainedBox(
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
                          value: '${creatorBooks.length} books',
                          leadingIcon: FontAwesomeIcons.book,
                        ),
                        DetailTile(
                          label: 'Works Count',
                          value: '${creatorWorks.length} works',
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
                      title: 'BOOKS (${creatorBooks.length})',
                      showDivider: creatorWorks.isNotEmpty,
                      children: creatorBooks
                          .map(
                            (BookEntity book) => BookListTile(
                              book: book,
                              onTap: () => BookQuickInfoDialog.show(context, book.id),
                            ),
                          )
                          .toList(),
                    ),
                    DetailSection(
                      title: 'WORKS (${creatorWorks.length})',
                      showDivider: false,
                      children: creatorWorks
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
