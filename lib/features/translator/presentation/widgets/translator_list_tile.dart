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
    return ListTile(
      leading: translator.image != null && translator.image!.isNotEmpty
          ? CircleAvatar(backgroundImage: NetworkImage(translator.image!))
          : Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange,
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
      title: Text(translator.name),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
