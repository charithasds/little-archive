import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/image_styles.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/sequence_entity.dart';

class SequenceListTile extends ConsumerWidget {
  const SequenceListTile({
    super.key,
    required this.sequence,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.bookCount = 0,
    this.workCount = 0,
  });

  final SequenceEntity sequence;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int bookCount;
  final int workCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

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
                tag: 'sequence_${sequence.id}',
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: ImageStyles.getAvatarBackgroundColor(theme),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.layers_rounded,
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
                      sequence.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$bookCount ${bookCount == 1 ? 'Book' : 'Books'} • $workCount ${workCount == 1 ? 'Work' : 'Works'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
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
