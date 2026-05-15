import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../domain/entities/work_entity.dart';

class WorkListTile extends ConsumerWidget {
  const WorkListTile({
    super.key,
    required this.work,
    this.onTap,
    this.onInfo,
    this.onEdit,
    this.onRemove,
  });

  final WorkEntity work;
  final VoidCallback? onTap;
  final VoidCallback? onInfo;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    final BookEntity? connectedBook = work.bookId != null
        ? ref.watch(bookProvider(work.bookId!)).value
        : null;

    final List<String> authorIdsToDisplay = work.authorIds;
    final List<String> translatorIdsToDisplay = work.translatorIds;
    final bool isTranslationToDisplay = work.isTranslation;

    final List<String> creatorIds = isTranslationToDisplay
        ? translatorIdsToDisplay
        : authorIdsToDisplay;
    final String creatorLabel = isTranslationToDisplay ? 'Translator' : 'Author';
    final int additionalCount = creatorIds.length > 1 ? creatorIds.length - 1 : 0;

    String? firstCreatorName;
    if (creatorIds.isNotEmpty) {
      if (isTranslationToDisplay) {
        firstCreatorName = ref.watch(translatorProvider(creatorIds.first)).value?.name;
      } else {
        firstCreatorName = ref.watch(authorProvider(creatorIds.first)).value?.name;
      }
    }

    final String? bookCover = connectedBook?.cover;

    String creatorText;
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
        onTap: onTap ?? onInfo,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Container(
                width: 54,
                height: 54 / Images.bookAspectRatio,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Images.getAvatarBackgroundColor(theme),
                  image: bookCover != null && bookCover.isNotEmpty
                      ? DecorationImage(
                          image: Images.getImageProvider(bookCover),
                          fit: BoxFit.contain,
                        )
                      : null,
                ),
                child: bookCover == null || bookCover.isEmpty
                    ? Icon(Icons.article_rounded, color: Images.getAvatarIconColor(theme), size: 28)
                    : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      work.title,
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
                      work.contentCategory.clientValue,
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
                  if (onInfo != null)
                    IconButton(
                      icon: Icon(Icons.info_outline_rounded, color: colorScheme.primary),
                      onPressed: onInfo,
                      tooltip: 'Info',
                    ),
                  if (onEdit != null)
                    IconButton(
                      icon: Icon(Icons.edit_note_rounded, color: colorScheme.primary),
                      onPressed: onEdit,
                      tooltip: 'Edit',
                    ),
                  if (onRemove != null)
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
