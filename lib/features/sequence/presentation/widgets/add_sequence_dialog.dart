import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/sequence_entity.dart';
import '../providers/sequence_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSequenceDialog extends ConsumerStatefulWidget {
  const AddSequenceDialog({super.key});

  @override
  ConsumerState<AddSequenceDialog> createState() => _AddSequenceDialogState();
}

class _AddSequenceDialogState extends ConsumerState<AddSequenceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authStateProvider).value;
      if (user == null) return;

      final newSequence = SequenceEntity(
        id: FirebaseFirestore.instance.collection('sequences').doc().id,
        userId: user.uid,
        name: _nameController.text.trim(),
        notes: _notesController.text.trim(),
        sequenceVolumeIds: [],
      );

      try {
        await ref.read(sequenceRepositoryProvider).addSequence(newSequence);
        if (mounted) {
          Navigator.of(context).pop(newSequence);
        }
      } on NoConnectionException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding sequence: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Sequence'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Add')),
      ],
    );
  }
}
