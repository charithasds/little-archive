import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/widgets/info_dialog_loading.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_metadata.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_rectangle_image.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../creator/domain/entities/creator_entity.dart';
import '../../../creator/presentation/providers/creator_provider.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
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
    final List<CreatorEntity>? creators = ref.watch(creatorsStreamProvider).value;
    final List<PublisherEntity>? publishers = ref.watch(publishersStreamProvider).value;

    final Widget content = async.when(
      data: (BookEntity? book) {
        if (book == null) {
          return const Text('Book not found');
        }

        final List<String> authorNames = <String>[];
        final List<String> translatorNames = <String>[];
        if (creators != null) {
          for (final String id in book.authorIds) {
            final CreatorEntity? a = creators.where((CreatorEntity x) => x.id == id).firstOrNull;
            if (a != null) {
              authorNames.add(a.name);
            }
          }
          for (final String id in book.translatorIds) {
            final CreatorEntity? t = creators.where((CreatorEntity x) => x.id == id).firstOrNull;
            if (t != null) {
              translatorNames.add(t.name);
            }
          }
        }

        String? publisherName;
        if (publishers != null && book.publisherId != null) {
          final PublisherEntity? p = publishers.where((PublisherEntity x) => x.id == book.publisherId).firstOrNull;
          if (p != null) {
            publisherName = p.name;
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InfoDialogImageRectangle(image: book.cover, icon: FontAwesomeIcons.book),
            const SizedBox(height: 16),
            Text(book.title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (book.originalTitle != null && book.originalTitle!.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                book.originalTitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const Divider(height: 24),
            if (authorNames.isNotEmpty) ...<Widget>[
              _buildField('Author', authorNames.join(', '), theme),
              const SizedBox(height: 4),
            ],
            if (book.isTranslation && translatorNames.isNotEmpty) ...<Widget>[
              _buildField('Translator', translatorNames.join(', '), theme),
              const SizedBox(height: 4),
            ],
            if (publisherName != null) ...<Widget>[
              _buildField('Publisher', publisherName, theme),
              const SizedBox(height: 4),
            ],
            if (authorNames.isNotEmpty || (book.isTranslation && translatorNames.isNotEmpty) || publisherName != null)
              const Divider(height: 24),
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

  Widget _buildField(String label, String value, ThemeData theme) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 90,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
}
