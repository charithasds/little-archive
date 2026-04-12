import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/image_styles.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/work_entity.dart';

class WorkListTile extends ConsumerWidget {
  const WorkListTile({
    super.key,
    required this.work,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.firstAuthorOrTranslatorName,
  });

  final WorkEntity work;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String? firstAuthorOrTranslatorName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    final bool isTranslation = work.isTranslation;
    final List<String> creatorIds = isTranslation ? work.translatorIds : work.authorIds;
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
                  height: 64,
                  decoration: BoxDecoration(
                    color: ImageStyles.getAvatarBackgroundColor(theme),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.article_rounded,
                    color: ImageStyles.getAvatarIconColor(theme),
                    size: 32,
                  ),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
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
                      '${work.contentCategory.clientValue} • ${work.readingStatus.clientValue}',
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
