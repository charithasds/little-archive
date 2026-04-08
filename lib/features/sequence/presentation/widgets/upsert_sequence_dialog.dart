import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../domain/entities/sequence_entity.dart';
import '../providers/upsert_sequence_controller.dart';

class UpsertSequenceDialog extends ConsumerStatefulWidget {
  const UpsertSequenceDialog({super.key});

  @override
  ConsumerState<UpsertSequenceDialog> createState() => _UpsertSequenceDialogState();
}

class _UpsertSequenceDialogState extends ConsumerState<UpsertSequenceDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final SequenceEntity? savedSequence = await ref
          .read(upsertSequenceControllerProvider.notifier)
          .saveSequence(existingSequence: null, name: _nameController.text.trim());

      if (mounted) {
        if (savedSequence != null) {
          SnackBars.showSuccess(context, 'Sequence added successfully');
          Navigator.of(context).pop(savedSequence);
        } else {
          final UpsertSequenceState state = ref.read(upsertSequenceControllerProvider);
          if (state.error != null) {
            SnackBars.showError(context, state.error!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UpsertSequenceState state = ref.watch(upsertSequenceControllerProvider);

    return AlertDialog(
      title: const Text('Add Sequence'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FormTextField(
                controller: _nameController,
                label: 'Name',
                hint: 'Sequence Name',
                isRequired: true,
                maxLength: 500,
                autofocus: true,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: state.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: state.isLoading ? null : _save,
          child: state.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
