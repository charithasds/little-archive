import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../domain/entities/translator_entity.dart';
import '../providers/upsert_translator_controller.dart';

class UpsertTranslatorDialog extends ConsumerStatefulWidget {
  const UpsertTranslatorDialog({super.key});

  @override
  ConsumerState<UpsertTranslatorDialog> createState() => _UpsertTranslatorDialogState();
}

class _UpsertTranslatorDialogState extends ConsumerState<UpsertTranslatorDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final TranslatorEntity? savedTranslator = await ref
          .read(upsertTranslatorControllerProvider.notifier)
          .saveTranslator(
            existingTranslator: null,
            name: _nameController.text.trim(),
            otherName: '',
            website: '',
            facebook: '',
          );

      if (mounted) {
        if (savedTranslator != null) {
          SnackBars.showSuccess(context, 'Translator added successfully');
          Navigator.of(context).pop(savedTranslator);
        } else {
          final UpsertTranslatorState state = ref.read(upsertTranslatorControllerProvider);
          if (state.error != null) {
            SnackBars.showError(context, state.error!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add Translator'),
    content: Form(
      key: _formKey,
      child: FormTextField(
        controller: _nameController,
        label: 'Name',
        hint: 'Translator Name',
        isRequired: true,
        maxLength: 500,
        autofocus: true,
      ),
    ),
    actions: <Widget>[
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
      ElevatedButton(onPressed: _save, child: const Text('Add')),
    ],
  );
}
