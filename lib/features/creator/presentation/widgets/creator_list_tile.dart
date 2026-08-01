import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/creator_entity.dart';

class CreatorListTile extends ConsumerWidget {
  const CreatorListTile({super.key, required this.creator, this.onTap, this.onEdit, this.onRemove});

  final CreatorEntity creator;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final int bookCount = creator.authoredBookIds.length + creator.translatedBookIds.length;
    final int workCount = creator.authoredWorkIds.length + creator.translatedWorkIds.length;

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
                tag: 'creator_${creator.id}',
                child: Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Images.getAvatarBackgroundColor(theme),
                    image: creator.image != null && creator.image!.isNotEmpty
                        ? DecorationImage(
                            image: Images.getImageProvider(creator.image),
                            fit: BoxFit.contain,
                          )
                        : null,
                  ),
                  child: creator.image == null || creator.image!.isEmpty
                      ? FaIcon(
                          FontAwesomeIcons.user,
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
                      creator.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (creator.otherName != null && creator.otherName!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        creator.otherName!,
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
