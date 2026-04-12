import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/image_styles.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/publisher_entity.dart';

class PublisherListTile extends ConsumerWidget {
  const PublisherListTile({
    super.key,
    required this.publisher,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final PublisherEntity publisher;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int bookCount = publisher.bookIds.length;

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
                tag: 'publisher_${publisher.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: ImageStyles.getAvatarBackgroundColor(theme),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: publisher.logo != null && publisher.logo!.isNotEmpty
                          ? _buildLogoImage(publisher.logo!, colorScheme, theme)
                          : _buildPlaceholder(theme),
                    ),
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
                      publisher.name,
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

  Widget _buildLogoImage(String logo, ColorScheme colorScheme, ThemeData theme) {
    if (logo.startsWith('http')) {
      return Image.network(
        logo,
        fit: BoxFit.contain,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) =>
            _buildPlaceholder(theme),
      );
    } else {
      try {
        return Image.memory(base64Decode(logo), fit: BoxFit.contain);
      } catch (e) {
        return _buildPlaceholder(theme);
      }
    }
  }

  Widget _buildPlaceholder(ThemeData theme) =>
      Icon(Icons.business_rounded, color: ImageStyles.getAvatarIconColor(theme), size: 32);
}
