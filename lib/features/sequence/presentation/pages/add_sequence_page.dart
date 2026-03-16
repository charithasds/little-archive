import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/snackbar_utils.dart';
import '../../domain/entities/sequence_entity.dart';
import '../providers/sequence_provider.dart';

class AddSequencePage extends ConsumerStatefulWidget {
  const AddSequencePage({super.key, this.existingSequence});

  final SequenceEntity? existingSequence;

  @override
  ConsumerState<AddSequencePage> createState() => _AddSequencePageState();
}

class _AddSequencePageState extends ConsumerState<AddSequencePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingSequence != null) {
      final SequenceEntity sequence = widget.existingSequence!;
      _nameController.text = sequence.name;
      _notesController.text = sequence.notes ?? '';
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final UserEntity? user = ref.read(authStateProvider).value;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final SequenceEntity newSequence = widget.existingSequence != null
          ? widget.existingSequence!.copyWith(
              name: _nameController.text.trim(),
              notes: _notesController.text.isEmpty ? null : _notesController.text.trim(),
            )
          : SequenceEntity(
              id: FirebaseFirestore.instance.collection('sequences').doc().id,
              name: _nameController.text.trim(),
              notes: _notesController.text.isEmpty ? null : _notesController.text.trim(),
              sequenceVolumeIds: const <String>[],
            );

      try {
        if (widget.existingSequence != null) {
          await ref.read(sequenceRepositoryProvider).updateSequence(newSequence);
        } else {
          await ref.read(sequenceRepositoryProvider).addSequence(newSequence);
        }
        if (mounted) {
          SnackBarUtils.showSuccess(
            context,
            widget.existingSequence != null
                ? 'Sequence updated successfully'
                : 'Sequence added successfully',
          );
          Navigator.of(context).pop();
        }
      } on NoConnectionException catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, e.message);
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showError(
            context,
            widget.existingSequence != null
                ? 'Error updating sequence: $e'
                : 'Error adding sequence: $e',
          );
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
      appBar: AppBar(
        title: Text(widget.existingSequence != null ? 'Edit Sequence' : 'Add Sequence'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
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

            FormTextField(
              controller: _nameController,
              label: 'Name',
              hint: 'Sequence name',
              prefixIcon: Icons.layers_outlined,
              maxLength: 500,
              isRequired: true,
            ),
            const SizedBox(height: 16),

            FormTextField(
              controller: _notesController,
              label: 'Notes',
              hint: 'Notes about this sequence',
              prefixIcon: Icons.notes_rounded,
              maxLines: 4,
              maxLength: 1000,
              alignLabelWithHint: true,
            ),
            const SizedBox(height: 32),

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
              label: Text(
                _isLoading
                    ? 'Saving...'
                    : (widget.existingSequence != null ? 'Update Sequence' : 'Save Sequence'),
              ),
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
