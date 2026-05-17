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
import '../../domain/entities/reader_entity.dart';
import '../../domain/usecases/reader_usecases.dart';
import '../providers/reader_provider.dart';

class ReaderDetailPage extends ConsumerWidget {
  const ReaderDetailPage({super.key, required this.readerId});
  final String readerId;

  Future<void> _handleRemove(BuildContext context, WidgetRef ref, ReaderEntity reader) async {
    await AppDialogs.removeEntity(
      context: context,
      entityType: 'Reader',
      entityName: reader.name,
      onConfirm: () async {
        await ref.read(removeReaderUseCaseProvider)(reader.id);
        if (context.mounted) {
          context.pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ReaderEntity?> readerAsync = ref.watch(readerProvider(readerId));
    final ThemeData theme = ref.watch(activeThemeDataProvider);

    return readerAsync.when(
      data: (ReaderEntity? reader) {
        if (reader == null) {
          return const Scaffold(
            body: ListEmptyState(
              icon: Icons.face_rounded,
              title: 'Reader Not Found',
              subtitle: 'This reader may have been removed.',
            ),
          );
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
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
                surfaceTintColor: theme.colorScheme.primary,
                scrolledUnderElevation: 1,
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded),
                    onPressed: () async {
                      await context.push('/readers/upsert', extra: reader);
                      ref.invalidate(readerProvider(readerId));
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _handleRemove(context, ref, reader),
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
                                  Icons.face_rounded,
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
                        if (reader.otherName != null && reader.otherName!.isNotEmpty)
                          DetailTile(
                            label: 'Other Name',
                            value: reader.otherName!,
                            leadingIcon: Icons.badge_rounded,
                          ),
                        DetailTile(
                          label: 'Books Count',
                          value: '${readerBooks.length} books',
                          leadingIcon: Icons.book_rounded,
                        ),
                        if (reader.email != null && reader.email!.isNotEmpty)
                          DetailTile(
                            label: 'Email',
                            value: reader.email!,
                            leadingIcon: Icons.email_rounded,
                            trailingIcon: Icons.open_in_new_rounded,
                            onTap: () => ExternalLauncher.launchEmail(reader.email!),
                          ),
                        if (reader.facebook != null && reader.facebook!.isNotEmpty)
                          DetailTile(
                            label: 'Facebook',
                            value: reader.facebook!,
                            leadingIcon: Icons.facebook_rounded,
                            trailingIcon: Icons.open_in_new_rounded,
                            onTap: () => ExternalLauncher.launchBrowser(reader.facebook!),
                          ),
                        if (reader.phoneNumber != null && reader.phoneNumber!.isNotEmpty)
                          DetailTile(
                            label: 'Phone Number',
                            value: reader.phoneNumber!,
                            leadingIcon: Icons.phone_rounded,
                            trailingIcon: Icons.open_in_new_rounded,
                            onTap: () => ExternalLauncher.launchPhone(reader.phoneNumber!),
                          ),
                        DetailTile(
                          label: 'Created',
                          value: DetailTile.formatDate(reader.createdDate),
                          leadingIcon: Icons.calendar_today_rounded,
                        ),
                        DetailTile(
                          label: 'Last Updated',
                          value: DetailTile.formatDate(reader.lastUpdated),
                          leadingIcon: Icons.update_rounded,
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
