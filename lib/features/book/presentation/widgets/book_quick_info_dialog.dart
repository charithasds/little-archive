import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/widgets/info_dialog_loading.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_metadata.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_rectangle_image.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/book_entity.dart';
import '../providers/book_provider.dart';

class BookQuickInfoDialog extends ConsumerWidget {
  const BookQuickInfoDialog({super.key, required this.bookId});

  final String bookId;

  static void show(BuildContext context, String bookId) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => BookQuickInfoDialog(bookId: bookId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final AsyncValue<BookEntity?> async = ref.watch(bookProvider(bookId));

    final Widget content = async.when(
      data: (BookEntity? book) {
        if (book == null) {
          return const Text('Book not found');
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InfoDialogImageRectangle(image: book.cover, icon: Icons.book_rounded),
            const SizedBox(height: 16),
            Text(book.title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (book.originalTitle != null && book.originalTitle!.isNotEmpty)
              Text(
                book.originalTitle!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const Divider(height: 32),
            InfoDialogMetadata(created: book.createdDate, updated: book.lastUpdated),
          ],
        );
      },
      loading: () => const InfoDialogLoading(),
      error: (Object e, _) => Text('Error: $e'),
    );

    return AlertDialog(
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Book Info'),
      content: SingleChildScrollView(child: SizedBox(width: 450, child: content)),
      actions: <Widget>[TextButton(onPressed: () => context.pop(), child: const Text('Close'))],
    );
  }
}
