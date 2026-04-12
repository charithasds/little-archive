import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/image_styles.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/reader_entity.dart';

class ReaderListTile extends ConsumerWidget {
  const ReaderListTile({
    super.key,
    required this.reader,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final ReaderEntity reader;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int bookCount = reader.bookIds.length;

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
                tag: 'reader_${reader.id}',
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: ImageStyles.getAvatarBackgroundColor(theme),
                  backgroundImage: reader.image != null && reader.image!.isNotEmpty
                      ? _getImageProvider(reader.image!)
                      : null,
                  child: reader.image == null || reader.image!.isEmpty
                      ? Icon(
                          Icons.face_rounded,
                          color: ImageStyles.getAvatarIconColor(theme),
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
                      reader.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$bookCount ${bookCount == 1 ? 'Book' : 'Books'}',
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
