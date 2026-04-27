import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/detail_widgets.dart';
import '../../../../core/shared/presentation/widgets/info_dialogs.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../book/presentation/widgets/book_list_tile.dart';
import '../../domain/entities/publisher_entity.dart';
import '../../domain/usecases/publisher_usecases.dart';
import '../providers/publisher_provider.dart';

class PublisherDetailPage extends ConsumerWidget {
  const PublisherDetailPage({super.key, required this.publisherId});
  final String publisherId;

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, String publisherId) async {
    final ThemeData theme = ref.read(activeThemeDataProvider);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 48),
        title: const Text('Remove Publisher'),
        content: const Text(
          'Are you sure you want to remove this publisher? This action cannot be undone.',
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
      await ref.read(removePublisherUseCaseProvider)(publisherId);
      SnackBars.showSuccess('Publisher removed successfully');
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
    final AsyncValue<PublisherEntity?> publisherAsync = ref.watch(publisherProvider(publisherId));
    final ThemeData theme = ref.watch(activeThemeDataProvider);

    return publisherAsync.when(
      data: (PublisherEntity? publisher) {
        if (publisher == null) {
          return const Scaffold(body: Center(child: Text('Publisher not found')));
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
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded),
                    onPressed: () => context.push('/publishers/add', extra: publisher),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded),
                    onPressed: () => _handleRemove(context, ref, publisher.id),
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
                    const SizedBox(height: 24),
                    DetailSection(
                      title: 'INFORMATION',
                      children: <Widget>[
                        if (publisher.otherName != null && publisher.otherName!.isNotEmpty)
                          DetailTile(
                            label: 'Other Name',
                            value: publisher.otherName!,
                            icon: Icons.badge_rounded,
                          ),
                        if (publisher.website != null && publisher.website!.isNotEmpty)
                          DetailTile(
                            label: 'Website',
                            value: publisher.website!,
                            icon: Icons.language_rounded,
                          ),
                        if (publisher.email != null && publisher.email!.isNotEmpty)
                          DetailTile(
                            label: 'Email',
                            value: publisher.email!,
                            icon: Icons.email_rounded,
                          ),
                        if (publisher.facebook != null && publisher.facebook!.isNotEmpty)
                          DetailTile(
                            label: 'Facebook',
                            value: publisher.facebook!,
                            icon: Icons.facebook_rounded,
                          ),
                        if (publisher.phoneNumber != null && publisher.phoneNumber!.isNotEmpty)
                          DetailTile(
                            label: 'Phone Number',
                            value: publisher.phoneNumber!,
                            icon: Icons.phone_rounded,
                          ),
                        DetailTile(
                          label: 'Created',
                          value: DetailTile.formatDate(publisher.createdDate),
                          icon: Icons.calendar_today_rounded,
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(publisher.lastUpdated),
                          icon: Icons.update_rounded,
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
                              onInfo: () => EntityQuickInfoDialog.show(context, book.id, 'book'),
                              onEdit: () => context.push('/books/add', extra: book),
                              onRemove: () {},
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
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (Object err, StackTrace stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
