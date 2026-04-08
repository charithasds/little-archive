import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/sequence_entity.dart';

/// A tile that displays summary information for a [SequenceEntity] in a list.
class SequenceListTile extends ConsumerWidget {
  /// Creates a [SequenceListTile].
  const SequenceListTile({
    super.key,
    required this.sequence,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.bookCount = 0,
    this.workCount = 0,
  });

  /// The sequence entity to display.
  final SequenceEntity sequence;

  /// Callback when the tile is tapped.
  final VoidCallback onTap;

  /// Callback when the edit button is tapped.
  final VoidCallback onEdit;

  /// Callback when the delete button is tapped.
  final VoidCallback onDelete;

  /// Number of books in this sequence.
  final int bookCount;

  /// Number of works in this sequence.
  final int workCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.layers_rounded, color: colorScheme.onPrimaryContainer, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    sequence.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$bookCount ${bookCount == 1 ? 'Book' : 'Books'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    '$workCount ${workCount == 1 ? 'Work' : 'Works'}',
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
}
