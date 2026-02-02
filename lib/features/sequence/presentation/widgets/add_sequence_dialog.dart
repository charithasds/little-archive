import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/sequence_entity.dart';
import '../../domain/repositories/sequence_repository.dart';
import '../providers/sequence_provider.dart';

class AddSequenceDialog extends ConsumerStatefulWidget {
  const AddSequenceDialog({super.key});

  @override
  ConsumerState<AddSequenceDialog> createState() => _AddSequenceDialogState();
}

class _AddSequenceDialogState extends ConsumerState<AddSequenceDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final UserEntity? user = ref.read<AsyncValue<UserEntity?>>(authStateProvider).value;
      if (user == null) {
        return;
      }

      final SequenceEntity newSequence = SequenceEntity(
        id: FirebaseFirestore.instance.collection('sequences').doc().id,
        userId: user.uid,
        name: _nameController.text.trim(),
        notes: _notesController.text.trim(),
        sequenceVolumeIds: const <String>[],
      );

      try {
        await ref.read<SequenceRepository>(sequenceRepositoryProvider).addSequence(newSequence);
        if (mounted) {
          SnackBarUtils.showSuccess(context, 'Sequence added successfully');
          Navigator.of(context).pop(newSequence);
        }
      } on NoConnectionException catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, e.message);
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, 'Error adding sequence: $e');
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
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (String? value) =>
                    value == null || value.isEmpty ? 'Name is required' : null,
                maxLength: 500,
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
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Add')),
      ],
    );
  }
}
