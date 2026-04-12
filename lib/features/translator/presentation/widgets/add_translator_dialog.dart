import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/button_styles.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/translator_entity.dart';
import '../providers/upsert_translator_controller.dart';

class AddTranslatorDialog extends ConsumerStatefulWidget {
  const AddTranslatorDialog({super.key});

  @override
  ConsumerState<AddTranslatorDialog> createState() => _AddTranslatorDialogState();
}

class _AddTranslatorDialogState extends ConsumerState<AddTranslatorDialog> {
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
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final UpsertTranslatorState state = ref.watch(upsertTranslatorControllerProvider);

    return AlertDialog(
      title: const Text('Add Translator'),
      content: Form(
        key: _formKey,
        child: FormTextField(
          controller: _nameController,
          label: 'Name',
          hint: 'Translator Name',
          isRequired: true,
          maxLength: 200,
          autofocus: true,
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: state.isLoading ? null : _save,
          style: ButtonStyles.getPrimaryFilledButtonStyle(
            theme,
          ).copyWith(minimumSize: WidgetStateProperty.all(const Size(100, 44))),
          child: state.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
