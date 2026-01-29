import 'package:flutter/material.dart';
import '../../domain/entities/work_entity.dart';

class WorkListTile extends StatelessWidget {
  final WorkEntity work;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String? firstAuthorOrTranslatorName;

  const WorkListTile({
    super.key,
    required this.work,
    required this.onTap,
    required this.onDelete,
    this.firstAuthorOrTranslatorName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine creator info
    final isTranslation = work.isTranslation;
    final creatorIds = isTranslation ? work.translatorIds : work.authorIds;
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.article_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    work.title,
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
                    '${work.workType.clientValue} • ${work.readingStatus.clientValue}',
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
}
