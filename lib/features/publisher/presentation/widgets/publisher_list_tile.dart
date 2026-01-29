import 'dart:convert';
import 'package:flutter/material.dart';
import '../../domain/entities/publisher_entity.dart';

class PublisherListTile extends StatelessWidget {
  final PublisherEntity publisher;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PublisherListTile({
    super.key,
    required this.publisher,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bookCount = publisher.bookIds.length;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 48,
                child: publisher.logo != null && publisher.logo!.isNotEmpty
                    ? _buildLogoImage(publisher.logo!, colorScheme)
                    : _buildPlaceholder(colorScheme),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    publisher.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$bookCount ${bookCount == 1 ? 'Book' : 'Books'}',
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

  Widget _buildLogoImage(String logo, ColorScheme colorScheme) {
    if (logo.startsWith('http')) {
      return Image.network(
        logo,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(colorScheme),
      );
    } else {
      try {
        return Image.memory(base64Decode(logo), fit: BoxFit.contain);
      } catch (e) {
        return _buildPlaceholder(colorScheme);
      }
    }
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.business_rounded,
        color: colorScheme.onPrimaryContainer,
        size: 24,
      ),
    );
  }
}
