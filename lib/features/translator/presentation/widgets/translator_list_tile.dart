import 'dart:convert';
import 'package:flutter/material.dart';
import '../../domain/entities/translator_entity.dart';

class TranslatorListTile extends StatelessWidget {
  final TranslatorEntity translator;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TranslatorListTile({
    super.key,
    required this.translator,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bookCount = translator.bookIds.length;
    final workCount = translator.workIds.length;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage:
                  translator.image != null && translator.image!.isNotEmpty
                  ? _getImageProvider(translator.image!)
                  : null,
              child: translator.image == null || translator.image!.isEmpty
                  ? Icon(
                      Icons.translate_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 24,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    translator.name,
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
                  Text(
                    '$workCount ${workCount == 1 ? 'Work' : 'Works'}',
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

  ImageProvider _getImageProvider(String image) {
    if (image.startsWith('http')) {
      return NetworkImage(image);
    } else {
      try {
        return MemoryImage(base64Decode(image));
      } catch (e) {
        return const AssetImage('assets/icon/app_icon.png'); // Fallback
      }
    }
  }
}
