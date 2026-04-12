import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/button_styles.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/author_entity.dart';
import '../providers/upsert_author_controller.dart';

class AddAuthorDialog extends ConsumerStatefulWidget {
  const AddAuthorDialog({super.key});

  @override
  ConsumerState<AddAuthorDialog> createState() => _AddAuthorDialogState();
}

class _AddAuthorDialogState extends ConsumerState<AddAuthorDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final AuthorEntity? savedAuthor = await ref
          .read(upsertAuthorControllerProvider.notifier)
          .saveAuthor(
            existingAuthor: null,
            name: _nameController.text.trim(),
            otherName: '',
            website: '',
            facebook: '',
          );

      if (mounted) {
        if (savedAuthor != null) {
          SnackBars.showSuccess(context, 'Author added successfully');
          Navigator.of(context).pop(savedAuthor);
        } else {
          final UpsertAuthorState state = ref.read(upsertAuthorControllerProvider);

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
    final UpsertAuthorState state = ref.watch(upsertAuthorControllerProvider);

    return AlertDialog(
      title: const Text('Add Author'),
      content: Form(
        key: _formKey,
        child: FormTextField(
          controller: _nameController,
          label: 'Name',
          hint: 'Author Name',
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
