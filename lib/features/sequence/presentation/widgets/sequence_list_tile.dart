import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/sequence_entity.dart';

class SequenceListTile extends ConsumerWidget {
  const SequenceListTile({
    super.key,
    required this.sequence,
    this.onTap,
    this.onEdit,
    this.onRemove,
    this.onInfo,
  });

  final SequenceEntity sequence;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final int volumeCount = sequence.sequenceVolumeIds.length;

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
              Hero(
                tag: 'sequence_${sequence.id}',
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Images.getAvatarBackgroundColor(theme),
                  ),
                  child: Icon(
                    Icons.layers_rounded,
                    color: Images.getAvatarIconColor(theme),
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
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$volumeCount ${volumeCount == 1 ? 'Volume' : 'Volumes'}',
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
                  if (onInfo != null)
                    IconButton(
                      icon: Icon(Icons.info_outline_rounded, color: colorScheme.primary),
                      onPressed: onInfo,
                      tooltip: 'Info',
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
