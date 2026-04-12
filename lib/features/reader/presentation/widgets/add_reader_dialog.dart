import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/button_styles.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/reader_entity.dart';
import '../providers/upsert_reader_controller.dart';

class AddReaderDialog extends ConsumerStatefulWidget {
  const AddReaderDialog({super.key});

  @override
  ConsumerState<AddReaderDialog> createState() => _AddReaderDialogState();
}

class _AddReaderDialogState extends ConsumerState<AddReaderDialog> {
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
            phoneNumber: '',
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
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final UpsertReaderState state = ref.watch(upsertReaderControllerProvider);

    return AlertDialog(
      title: const Text('Add Reader'),
      content: Form(
        key: _formKey,
        child: FormTextField(
          controller: _nameController,
          label: 'Name',
          hint: 'Reader Name',
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
