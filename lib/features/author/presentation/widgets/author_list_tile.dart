import 'package:flutter/material.dart';
import '../../domain/entities/author_entity.dart';

class AuthorListTile extends StatelessWidget {
  final AuthorEntity author;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AuthorListTile({
    super.key,
    required this.author,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: author.image != null && author.image!.isNotEmpty
          ? CircleAvatar(backgroundImage: NetworkImage(author.image!))
          : Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueGrey,
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
      title: Text(author.name),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
