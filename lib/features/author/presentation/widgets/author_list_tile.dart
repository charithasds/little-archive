import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/author_entity.dart';

class AuthorListTile extends ConsumerWidget {
  const AuthorListTile({super.key, required this.author, this.onTap, this.onEdit, this.onRemove});

  final AuthorEntity author;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final int bookCount = author.bookIds.length;
    final int workCount = author.workIds.length;

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
                tag: 'author_${author.id}',
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Images.getAvatarBackgroundColor(theme),
                    image: author.image != null && author.image!.isNotEmpty
                        ? DecorationImage(
                            image: Images.getImageProvider(author.image),
                            fit: BoxFit.contain,
                          )
                        : null,
                  ),
                  child: author.image == null || author.image!.isEmpty
                      ? Icon(
                          Icons.person_rounded,
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
                      author.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (author.otherName != null && author.otherName!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        author.otherName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      '$bookCount ${bookCount == 1 ? 'Book' : 'Books'} • $workCount ${workCount == 1 ? 'Work' : 'Works'}',
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
