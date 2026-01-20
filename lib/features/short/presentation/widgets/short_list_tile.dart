import 'package:flutter/material.dart';
import '../../domain/entities/short_entity.dart';

class ShortListTile extends StatelessWidget {
  final ShortEntity short;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ShortListTile({
    super.key,
    required this.short,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildPlaceholder(),
      title: Text(
        short.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        short.isTranslation
            ? "${short.translatorIds.isNotEmpty ? short.translatorIds.first : 'No Translators'} + ${short.translatorIds.length}"
            : "${short.authorIds.isNotEmpty ? short.authorIds.first : 'No Authors'} + ${short.authorIds.length}",
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
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.article_rounded, color: Colors.grey),
    );
  }
}
