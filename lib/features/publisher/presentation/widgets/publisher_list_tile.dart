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
    return ListTile(
      leading: publisher.logo != null && publisher.logo!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                publisher.logo!,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            )
          : Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.business, color: Colors.grey),
            ),
      title: Text(publisher.name),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
