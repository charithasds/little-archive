import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              icon: Icons.business_rounded,
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
                    icon: const Icon(Icons.edit_note_rounded),
                    onPressed: () async {
                      await context.push('/publishers/upsert', extra: publisher);
                      ref.invalidate(publisherProvider(publisherId));
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Images.getAvatarBackgroundColor(theme),
                            image: publisher.logo != null && publisher.logo!.isNotEmpty
                                ? DecorationImage(
                                    image: Images.getImageProvider(publisher.logo),
                                    fit: BoxFit.contain,
                                  )
                                : null,
                          ),
                          child: publisher.logo == null || publisher.logo!.isEmpty
                              ? Icon(
                                  Icons.business_rounded,
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
                        if (publisher.otherName != null && publisher.otherName!.isNotEmpty)
                          DetailTile(
                            label: 'Other Name',
                            value: publisher.otherName!,
                            leadingIcon: Icons.badge_rounded,
                          ),
                        DetailTile(
                          label: 'Books Count',
                          value: '${publisherBooks.length} books',
                          leadingIcon: Icons.book_rounded,
                        ),
                        if (publisher.website != null && publisher.website!.isNotEmpty)
                          DetailTile(
                            label: 'Website',
                            value: publisher.website!,
                            leadingIcon: Icons.language_rounded,
                            trailingIcon: Icons.open_in_new_rounded,
                            onTap: () => ExternalLauncher.launchBrowser(publisher.website!),
                          ),
                        if (publisher.email != null && publisher.email!.isNotEmpty)
                          DetailTile(
                            label: 'Email',
                            value: publisher.email!,
                            leadingIcon: Icons.email_rounded,
                            trailingIcon: Icons.open_in_new_rounded,
                            onTap: () => ExternalLauncher.launchEmail(publisher.email!),
                          ),
                        if (publisher.facebook != null && publisher.facebook!.isNotEmpty)
                          DetailTile(
                            label: 'Facebook',
                            value: publisher.facebook!,
                            leadingIcon: Icons.facebook_rounded,
                            trailingIcon: Icons.open_in_new_rounded,
                            onTap: () => ExternalLauncher.launchBrowser(publisher.facebook!),
                          ),
                        if (publisher.phoneNumber != null && publisher.phoneNumber!.isNotEmpty)
                          DetailTile(
                            label: 'Phone Number',
                            value: publisher.phoneNumber!,
                            leadingIcon: Icons.phone_rounded,
                            trailingIcon: Icons.open_in_new_rounded,
                            onTap: () => ExternalLauncher.launchPhone(publisher.phoneNumber!),
                          ),
                        DetailTile(
                          label: 'Created',
                          value: DetailTile.formatDate(publisher.createdDate),
                          leadingIcon: Icons.calendar_today_rounded,
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(publisher.lastUpdated),
                          leadingIcon: Icons.update_rounded,
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
                              onInfo: () => BookQuickInfoDialog.show(context, book.id),
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
