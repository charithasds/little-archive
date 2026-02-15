import 'dart:convert';
import 'package:flutter/material.dart';
import '../../domain/entities/author_entity.dart';

class AuthorListTile extends StatelessWidget {
  const AuthorListTile({
    super.key,
    required this.author,
    required this.onTap,
    required this.onDelete,
  });
  final AuthorEntity author;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final int bookCount = author.bookIds.length;
    final int workCount = author.workIds.length;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
              backgroundImage: author.image != null && author.image!.isNotEmpty
                  ? _getImageProvider(author.image!)
                  : null,
              child: author.image == null || author.image!.isEmpty
                  ? Icon(Icons.person_rounded, color: colorScheme.onPrimaryContainer, size: 24)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    author.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$bookCount ${bookCount == 1 ? 'Book' : 'Books'}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    '$workCount ${workCount == 1 ? 'Work' : 'Works'}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
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
        return const AssetImage('assets/icon/app_icon.png');
      }
    }
  }
}
