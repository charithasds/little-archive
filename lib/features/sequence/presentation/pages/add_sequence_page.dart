import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/sequence_entity.dart';
import '../providers/sequence_provider.dart';

class AddSequencePage extends ConsumerStatefulWidget {
  const AddSequencePage({super.key});

  @override
  ConsumerState<AddSequencePage> createState() => _AddSequencePageState();
}

class _AddSequencePageState extends ConsumerState<AddSequencePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final UserEntity? user = ref.read(authStateProvider).value;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final SequenceEntity newSequence = SequenceEntity(
        id: FirebaseFirestore.instance.collection('sequences').doc().id,
        userId: user.uid,
        name: _nameController.text.trim(),
        notes: _notesController.text.isEmpty ? '' : _notesController.text.trim(),
        sequenceVolumeIds: const <String>[],
      );

      try {
        await ref.read(sequenceRepositoryProvider).addSequence(newSequence);
        if (mounted) {
          SnackBarUtils.showSuccess(context, 'Sequence added successfully');
          Navigator.of(context).pop();
        }
      } on NoConnectionException catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, e.message);
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, 'Error adding sequence: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Sequence'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            // Header Icon
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primaryContainer,
                  border: Border.all(color: colorScheme.primary, width: 3),
                ),
                child: Icon(Icons.layers_rounded, size: 48, color: colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: 32),

            // Form Fields
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Sequence name',
                prefixIcon: const Icon(Icons.layers_outlined),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.error),
                ),
              ),
              validator: (String? v) => v!.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes',
                hintText: 'Notes about this sequence',
                prefixIcon: const Icon(Icons.notes_rounded),
                alignLabelWithHint: true,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
              maxLines: 4,
              maxLength: 1000,
            ),
            const SizedBox(height: 32),

            // Save Button
            FilledButton.icon(
              onPressed: _isLoading ? null : _save,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_isLoading ? 'Saving...' : 'Save Sequence'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
