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
import '../../domain/entities/reader_entity.dart';
import '../../domain/usecases/reader_usecases.dart';
import '../providers/reader_provider.dart';

class ReaderDetailPage extends ConsumerWidget {
  const ReaderDetailPage({super.key, required this.readerId});
  final String readerId;

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, String readerId) async {
    final ThemeData theme = ref.read(activeThemeDataProvider);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 48),
        title: const Text('Remove Reader'),
        content: const Text(
          'Are you sure you want to remove this reader? This action cannot be undone.',
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
      await ref.read(removeReaderUseCaseProvider)(readerId);
      SnackBars.showSuccess('Reader removed successfully');
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
    final AsyncValue<ReaderEntity?> readerAsync = ref.watch(readerProvider(readerId));
    final ThemeData theme = ref.watch(activeThemeDataProvider);

    return readerAsync.when(
      data: (ReaderEntity? reader) {
        if (reader == null) {
          return const Scaffold(body: Center(child: Text('Reader not found')));
        }

        final AsyncValue<List<BookEntity>> booksAsync = ref.watch(booksStreamProvider);
        final List<BookEntity> readerBooks =
            (booksAsync.value ?? <BookEntity>[])
                .where((BookEntity b) => reader.bookIds.contains(b.id))
                .toList()
              ..sort(
                (BookEntity a, BookEntity b) =>
                    a.title.toLowerCase().compareTo(b.title.toLowerCase()),
              );

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar.large(
                title: Text(reader.name),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded),
                    onPressed: () => context.push('/readers/add', extra: reader),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_rounded),
                    onPressed: () => _handleRemove(context, ref, reader.id),
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
                      tag: 'reader_${reader.id}',
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Images.getAvatarBackgroundColor(theme),
                          image: reader.image != null && reader.image!.isNotEmpty
                              ? DecorationImage(
                                  image: Images.getImageProvider(reader.image),
                                  fit: BoxFit.contain,
                                )
                              : null,
                        ),
                        child: reader.image == null || reader.image!.isEmpty
                            ? Icon(
                                Icons.chrome_reader_mode_rounded,
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
                        if (reader.otherName != null && reader.otherName!.isNotEmpty)
                          DetailTile(
                            label: 'Other Name',
                            value: reader.otherName!,
                            icon: Icons.badge_rounded,
                          ),
                        if (reader.email != null && reader.email!.isNotEmpty)
                          DetailTile(
                            label: 'Email',
                            value: reader.email!,
                            icon: Icons.email_rounded,
                          ),
                        if (reader.facebook != null && reader.facebook!.isNotEmpty)
                          DetailTile(
                            label: 'Facebook',
                            value: reader.facebook!,
                            icon: Icons.facebook_rounded,
                          ),
                        if (reader.phoneNumber != null && reader.phoneNumber!.isNotEmpty)
                          DetailTile(
                            label: 'Phone Number',
                            value: reader.phoneNumber!,
                            icon: Icons.phone_rounded,
                          ),
                        DetailTile(
                          label: 'Created',
                          value: DetailTile.formatDate(reader.createdDate),
                          icon: Icons.calendar_today_rounded,
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(reader.lastUpdated),
                          icon: Icons.update_rounded,
                        ),
                      ],
                    ),
                    DetailSection(
                      title: 'BOOKS (${readerBooks.length})',
                      showDivider: false,
                      children: readerBooks
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
