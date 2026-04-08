import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../domain/entities/reader_entity.dart';
import '../providers/upsert_reader_controller.dart';

class UpsertReaderDialog extends ConsumerStatefulWidget {
  const UpsertReaderDialog({super.key});

  @override
  ConsumerState<UpsertReaderDialog> createState() => _UpsertReaderDialogState();
}

class _UpsertReaderDialogState extends ConsumerState<UpsertReaderDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final ReaderEntity? savedReader = await ref
          .read(upsertReaderControllerProvider.notifier)
          .saveReader(
            existingReader: null,
            name: _nameController.text.trim(),
            email: '',
            facebook: '',
          );

      if (mounted) {
        if (savedReader != null) {
          SnackBars.showSuccess(context, 'Reader added successfully');
          Navigator.of(context).pop(savedReader);
        } else {
          final UpsertReaderState state = ref.read(upsertReaderControllerProvider);
          if (state.error != null) {
            SnackBars.showError(context, state.error!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add Reader'),
    content: Form(
      key: _formKey,
      child: FormTextField(
        controller: _nameController,
        label: 'Name',
        hint: 'Reader Name',
        isRequired: true,
        maxLength: 500,
      ),
    ),
    actions: <Widget>[
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
      ElevatedButton(onPressed: _save, child: const Text('Add')),
    ],
  );
}
