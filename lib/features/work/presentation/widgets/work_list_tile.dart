import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../domain/entities/work_entity.dart';

class WorkListTile extends ConsumerWidget {
  const WorkListTile({super.key, required this.work, this.onTap, this.onEdit, this.onRemove});

  final WorkEntity work;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<String> creatorIds = work.isTranslation ? work.translatorIds : work.authorIds;
    final String creatorLabel = work.isTranslation ? 'Translator' : 'Author';
    final int additionalCount = creatorIds.length > 1 ? creatorIds.length - 1 : 0;
    final BookEntity? connectedBook = work.bookId != null
        ? ref.watch(bookProvider(work.bookId!)).value
        : null;
    final String? bookCover = connectedBook?.cover;
    String? firstCreatorName;
    String creatorText;

    if (creatorIds.isNotEmpty) {
      if (work.isTranslation) {
        firstCreatorName = ref.watch(translatorProvider(creatorIds.first)).value?.name;
      } else {
        firstCreatorName = ref.watch(authorProvider(creatorIds.first)).value?.name;
      }
    }

    if (creatorIds.isNotEmpty) {
      if (firstCreatorName != null && firstCreatorName.isNotEmpty) {
        creatorText = firstCreatorName;

        if (additionalCount > 0) {
          creatorText += ' + $additionalCount';
        }
      } else {
        creatorText = 'Loading...';
      }
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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Hero(
                tag: 'work_${work.id}',
                child: Container(
                  width: 64,
                  height: 64 / Images.bookAspectRatio,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Images.getAvatarBackgroundColor(theme),
                    image: bookCover != null && bookCover.isNotEmpty
                        ? DecorationImage(
                            image: Images.getImageProvider(bookCover),
                            fit: BoxFit.contain,
                          )
                        : null,
                  ),
                  child: bookCover == null || bookCover.isEmpty
                      ? FaIcon(
                          FontAwesomeIcons.fileLines,
                          color: Images.getAvatarIconColor(theme),
                          size: 32,
                        )
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
                      work.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (onEdit != null)
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.penToSquare, color: colorScheme.primary),
                      onPressed: onEdit,
                      tooltip: 'Edit',
                    ),
                  if (onRemove != null)
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.trashCan, color: colorScheme.error),
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
