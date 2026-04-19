import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/book_entity.dart';

class BookListTile extends ConsumerWidget {
  const BookListTile({
    super.key,
    required this.book,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.firstCreatorName,
  });

  final BookEntity book;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String? firstCreatorName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    final List<String> creatorIds = book.isTranslation ? book.translatorIds : book.authorIds;
    final String creatorLabel = book.isTranslation ? 'Translator' : 'Author';
    final int additionalCount = creatorIds.length > 1 ? creatorIds.length - 1 : 0;
    String creatorText;

    if (book.compilationType == CompilationType.single ||
        book.compilationType == CompilationType.collection ||
        (book.compilationType == CompilationType.anthology && book.isTranslation)) {
      if (firstCreatorName != null && firstCreatorName!.isNotEmpty) {
        creatorText = firstCreatorName!;

        if (additionalCount > 0) {
          creatorText += ' + $additionalCount';
        }
      } else {
        creatorText = 'No ${creatorLabel}s';
      }
    } else {
      creatorText = 'Various ${creatorLabel}s';
    }

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: colorScheme.primaryContainer.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Hero(
                tag: 'book_${book.id}',
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Images.getAvatarBackgroundColor(theme),
                  backgroundImage: book.cover != null && book.cover!.isNotEmpty
                      ? Images.getImageProvider(book.cover)
                      : null,
                  child: book.cover == null || book.cover!.isEmpty
                      ? Icon(Icons.book_rounded, color: Images.getAvatarIconColor(theme), size: 32)
                      : null,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      creatorText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${book.collectionStatus.clientValue} • ${book.readingStatus.clientValue}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit_note_rounded, color: colorScheme.primary),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_sweep_rounded, color: colorScheme.error),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
