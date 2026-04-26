import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../domain/entities/book_entity.dart';

class BookListTile extends ConsumerWidget {
  const BookListTile({
    super.key,
    required this.book,
    required this.onTap,
    required this.onEdit,
    required this.onRemove,
  });

  final BookEntity book;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    final List<String> creatorIds = book.isTranslation ? book.translatorIds : book.authorIds;
    final String creatorLabel = book.isTranslation ? 'Translator' : 'Author';
    final int additionalCount = creatorIds.length > 1 ? creatorIds.length - 1 : 0;

    String? firstCreatorName;
    if (creatorIds.isNotEmpty) {
      if (book.isTranslation) {
        firstCreatorName = ref
            .watch<AsyncValue<String?>>(translatorNameProvider(creatorIds.first))
            .value;
      } else {
        firstCreatorName = ref
            .watch<AsyncValue<String?>>(authorNameProvider(creatorIds.first))
            .value;
      }
    }

    String creatorText;
    if (book.compilationType == CompilationType.standalone ||
        book.compilationType == CompilationType.collection ||
        (book.compilationType == CompilationType.anthology && book.isTranslation)) {
      if (firstCreatorName != null && firstCreatorName.isNotEmpty) {
        creatorText = firstCreatorName;
        if (additionalCount > 0) {
          creatorText += ' + $additionalCount';
        }
      } else if (creatorIds.isNotEmpty) {
        creatorText = 'Loading...';
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
                child: Container(
                  width: 54,
                  height: 54 / Images.bookAspectRatio,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Images.getAvatarBackgroundColor(theme),
                    image: book.cover != null && book.cover!.isNotEmpty
                        ? DecorationImage(
                            image: Images.getImageProvider(book.cover),
                            fit: BoxFit.contain,
                          )
                        : null,
                  ),
                  child: book.cover == null || book.cover!.isEmpty
                      ? Icon(Icons.book_rounded, color: Images.getAvatarIconColor(theme), size: 28)
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
                      maxLines: 1,
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
                      book.compilationType.clientValue,
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
                    icon: Icon(Icons.delete_rounded, color: colorScheme.error),
                    onPressed: onRemove,
                    tooltip: 'Remove',
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
