import 'package:flutter/material.dart';
import '../../domain/entities/book_entity.dart';

class BookListTile extends StatelessWidget {
  final BookEntity book;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BookListTile({
    super.key,
    required this.book,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: (book.cover != null && book.cover!.isNotEmpty)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                book.cover!,
                width: 40,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
      title: Text(
        book.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        book.isTranslation
            ? "${book.translatorIds.isNotEmpty ? book.translatorIds.first : 'No Translators'} + ${book.translatorIds.length}"
            : "${book.authorIds.isNotEmpty ? book.authorIds.first : 'No Authors'} + ${book.authorIds.length}",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 40,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.book_rounded, color: Colors.grey),
    );
  }
}
