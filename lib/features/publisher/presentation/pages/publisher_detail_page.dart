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
import '../../domain/entities/publisher_entity.dart';
import '../../domain/usecases/publisher_usecases.dart';
import '../providers/publisher_provider.dart';

class PublisherDetailPage extends ConsumerWidget {
  const PublisherDetailPage({super.key, required this.publisherId});
  final String publisherId;

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, PublisherEntity publisher) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Publisher',
      entityName: publisher.name,
      onConfirm: () async {
        await ref.read(removePublisherUseCaseProvider)(publisher.id);
        if (context.mounted) {
          context.pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PublisherEntity?> publisherAsync = ref.watch(publisherProvider(publisherId));
    final ThemeData theme = ref.watch(activeThemeDataProvider);

    return publisherAsync.when(
      data: (PublisherEntity? publisher) {
        if (publisher == null) {
          return const Scaffold(
            body: ListEmptyState(
              icon: FontAwesomeIcons.building,
              title: 'Publisher Not Found',
              subtitle: 'This publisher may have been removed.',
            ),
          );
        }

        final AsyncValue<List<BookEntity>> booksAsync = ref.watch(booksStreamProvider);
        final List<BookEntity> publisherBooks =
            (booksAsync.value ?? <BookEntity>[])
                .where((BookEntity b) => b.publisherId == publisher.id)
                .toList()
              ..sort(
                (BookEntity a, BookEntity b) =>
                    a.title.toLowerCase().compareTo(b.title.toLowerCase()),
              );

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar.large(
                title: Text(publisher.name),
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
                surfaceTintColor: theme.colorScheme.primary,
                scrolledUnderElevation: 1,
                actions: <Widget>[
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.penToSquare),
                    onPressed: () async {
                      await context.push('/publishers/upsert', extra: publisher);
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.trash),
                    onPressed: () => _handleRemove(context, ref, publisher),
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
                        tag: 'publisher_${publisher.id}',
                        child: Container(
                          width: 240,
                          height: 240,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: Images.getAvatarBackgroundColor(theme),
                            image: publisher.logo != null && publisher.logo!.isNotEmpty
                                ? DecorationImage(
                                    image: Images.getImageProvider(publisher.logo),
                                    fit: BoxFit.contain,
                                  )
                                : null,
                          ),
                          child: publisher.logo == null || publisher.logo!.isEmpty
                              ? FaIcon(
                                  FontAwesomeIcons.building,
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
                        DetailTile(
                          label: 'Self Publisher',
                          value: publisher.isSelfPublisher ? 'Yes' : 'No',
                          leadingIcon: FontAwesomeIcons.briefcase,
                        ),
                        if (publisher.otherName != null && publisher.otherName!.isNotEmpty)
                          DetailTile(
                            label: 'Other Name',
                            value: publisher.otherName!,
                            leadingIcon: FontAwesomeIcons.idBadge,
                          ),
                        DetailTile(
                          label: 'Books Count',
                          value: '${publisherBooks.length} books',
                          leadingIcon: FontAwesomeIcons.book,
                        ),
                        if (publisher.website != null && publisher.website!.isNotEmpty)
                          DetailTile(
                            label: 'Website',
                            value: publisher.website!,
                            leadingIcon: FontAwesomeIcons.globe,
                            trailingIcon: FontAwesomeIcons.arrowUpRightFromSquare,
                            onTap: () => ExternalLauncher.launchBrowser(publisher.website!),
                          ),
                        if (publisher.email != null && publisher.email!.isNotEmpty)
                          DetailTile(
                            label: 'Email',
                            value: publisher.email!,
                            leadingIcon: FontAwesomeIcons.envelope,
                            trailingIcon: FontAwesomeIcons.arrowUpRightFromSquare,
                            onTap: () => ExternalLauncher.launchEmail(publisher.email!),
                          ),
                        if (publisher.facebook != null && publisher.facebook!.isNotEmpty)
                          DetailTile(
                            label: 'Facebook',
                            value: publisher.facebook!,
                            leadingIcon: FontAwesomeIcons.facebook,
                            trailingIcon: FontAwesomeIcons.arrowUpRightFromSquare,
                            onTap: () => ExternalLauncher.launchBrowser(publisher.facebook!),
                          ),
                        if (publisher.phoneNumber != null && publisher.phoneNumber!.isNotEmpty)
                          DetailTile(
                            label: 'Phone Number',
                            value: publisher.phoneNumber!,
                            leadingIcon: FontAwesomeIcons.phone,
                            trailingIcon: FontAwesomeIcons.arrowUpRightFromSquare,
                            onTap: () => ExternalLauncher.launchPhone(publisher.phoneNumber!),
                          ),
                        DetailTile(
                          label: 'Created',
                          value: DetailTile.formatDate(publisher.createdDate),
                          leadingIcon: FontAwesomeIcons.calendar,
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(publisher.lastUpdated),
                          leadingIcon: FontAwesomeIcons.clockRotateLeft,
                        ),
                      ],
                    ),
                    DetailSection(
                      title: 'BOOKS (${publisherBooks.length})',
                      showDivider: false,
                      children: publisherBooks
                          .map(
                            (BookEntity book) => BookListTile(
                              book: book,
                              onTap: () => BookQuickInfoDialog.show(context, book.id),
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
