import 'package:flutter/material.dart';
import '../../domain/entities/sequence_entity.dart';

class SequenceListTile extends StatelessWidget {
  final SequenceEntity sequence;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SequenceListTile({
    super.key,
    required this.sequence,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.layers, color: Colors.indigo),
      ),
      title: Text(sequence.name),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
