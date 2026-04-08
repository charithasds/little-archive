import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/reader_entity.dart';

/// A tile that displays summary information for a [ReaderEntity] in a list.
class ReaderListTile extends ConsumerWidget {
  /// Creates a [ReaderListTile].
  const ReaderListTile({
    super.key,
    required this.reader,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  /// The reader entity to display.
  final ReaderEntity reader;

  /// Callback when the tile is tapped.
  final VoidCallback onTap;

  /// Callback when the edit button is tapped.
  final VoidCallback onEdit;

  /// Callback when the delete button is tapped.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int bookCount = reader.bookIds.length;

    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 24,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: reader.image != null && reader.image!.isNotEmpty
                  ? _getImageProvider(reader.image!)
                  : null,
              child: reader.image == null || reader.image!.isEmpty
                  ? Icon(Icons.face_rounded, color: colorScheme.onPrimaryContainer, size: 24)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    reader.name,
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

  ImageProvider _getImageProvider(String image) {
    if (image.startsWith('http')) {
      return NetworkImage(image);
    } else {
      try {
        return MemoryImage(base64Decode(image));
      } catch (e) {
        return const AssetImage('assets/icon/app_icon.png');
      }
    }
  }
}
