import 'package:flutter/material.dart';
import '../../domain/entities/reader_entity.dart';

class ReaderListTile extends StatelessWidget {
  final ReaderEntity reader;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ReaderListTile({
    super.key,
    required this.reader,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: reader.image != null && reader.image!.isNotEmpty
          ? CircleAvatar(backgroundImage: NetworkImage(reader.image!))
          : Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal,
              ),
              child: const Icon(Icons.face, color: Colors.white),
            ),
      title: Text(reader.name),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
