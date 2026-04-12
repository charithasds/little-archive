import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/button_styles.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/sequence_entity.dart';
import '../providers/upsert_sequence_controller.dart';

class AddSequenceDialog extends ConsumerStatefulWidget {
  const AddSequenceDialog({super.key});

  @override
  ConsumerState<AddSequenceDialog> createState() => _AddSequenceDialogState();
}

class _AddSequenceDialogState extends ConsumerState<AddSequenceDialog> {
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
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final UpsertSequenceState state = ref.watch(upsertSequenceControllerProvider);

    return AlertDialog(
      title: const Text('Add Sequence'),
      content: Form(
        key: _formKey,
        child: FormTextField(
          controller: _nameController,
          label: 'Name',
          hint: 'Sequence Name',
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
