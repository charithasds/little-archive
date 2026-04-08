import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/book_entity.dart';

/// A tile that displays summary information for a [BookEntity] in a list.
class BookListTile extends ConsumerWidget {
  /// Creates a [BookListTile].
  const BookListTile({
    super.key,
    required this.book,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.firstAuthorOrTranslatorName,
  });

  /// The book entity to display.
  final BookEntity book;

  /// Callback when the tile is tapped.
  final VoidCallback onTap;

  /// Callback when the edit button is tapped.
  final VoidCallback onEdit;

  /// Callback when the delete button is tapped.
  final VoidCallback onDelete;

  /// Name of the first author or translator (if available).
  final String? firstAuthorOrTranslatorName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    final bool isTranslation = book.isTranslation;
    final List<String> creatorIds = isTranslation ? book.translatorIds : book.authorIds;
    final String creatorLabel = isTranslation ? 'Translator' : 'Author';
    final int additionalCount = creatorIds.length > 1 ? creatorIds.length - 1 : 0;

    String creatorText;
    if (firstAuthorOrTranslatorName != null && firstAuthorOrTranslatorName!.isNotEmpty) {
      creatorText = firstAuthorOrTranslatorName!;
      if (additionalCount > 0) {
        creatorText += ' +$additionalCount';
      }
    } else if (creatorIds.isNotEmpty) {
      creatorText = '$creatorLabel${additionalCount > 0 ? ' +$additionalCount' : ''}';
    } else {
      creatorText = 'No ${creatorLabel}s';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 64,
                child: book.cover != null && book.cover!.isNotEmpty
                    ? _buildCoverImage(book.cover!, colorScheme)
                    : _buildPlaceholder(colorScheme),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    creatorText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    '${book.collectionStatus.clientValue} • ${book.readingStatus.clientValue}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(String cover, ColorScheme colorScheme) {
    if (cover.startsWith('http')) {
      return Image.network(
        cover,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) =>
            _buildPlaceholder(colorScheme),
      );
    } else {
      try {
        return Image.memory(base64Decode(cover), fit: BoxFit.cover);
      } catch (e) {
        return _buildPlaceholder(colorScheme);
      }
    }
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) => Container(
    decoration: BoxDecoration(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(Icons.book_rounded, color: colorScheme.onPrimaryContainer, size: 24),
  );
}
