import 'dart:convert';
import 'package:flutter/material.dart';
import '../../domain/entities/book_entity.dart';

class BookListTile extends StatelessWidget {
  final BookEntity book;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String? firstAuthorOrTranslatorName;

  const BookListTile({
    super.key,
    required this.book,
    required this.onTap,
    required this.onDelete,
    this.firstAuthorOrTranslatorName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine creator info
    final isTranslation = book.isTranslation;
    final creatorIds = isTranslation ? book.translatorIds : book.authorIds;
    final creatorLabel = isTranslation ? 'Translator' : 'Author';
    final additionalCount = creatorIds.length > 1 ? creatorIds.length - 1 : 0;

    String creatorText;
    if (firstAuthorOrTranslatorName != null &&
        firstAuthorOrTranslatorName!.isNotEmpty) {
      creatorText = firstAuthorOrTranslatorName!;
      if (additionalCount > 0) {
        creatorText += ' +$additionalCount';
      }
    } else if (creatorIds.isNotEmpty) {
      creatorText =
          '$creatorLabel${additionalCount > 0 ? ' +$additionalCount' : ''}';
    } else {
      creatorText = 'No ${creatorLabel}s';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
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
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    creatorText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${book.collectionStatus.clientValue} • ${book.readingStatus.clientValue}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: colorScheme.error,
              ),
              onPressed: onDelete,
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
        errorBuilder: (context, error, stackTrace) =>
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

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.book_rounded,
        color: colorScheme.onPrimaryContainer,
        size: 24,
      ),
    );
  }
}
