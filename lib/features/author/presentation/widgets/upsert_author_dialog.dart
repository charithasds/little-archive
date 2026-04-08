import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../domain/entities/author_entity.dart';
import '../providers/upsert_author_controller.dart';

class UpsertAuthorDialog extends ConsumerStatefulWidget {
  const UpsertAuthorDialog({super.key});

  @override
  ConsumerState<UpsertAuthorDialog> createState() => _UpsertAuthorDialogState();
}

class _UpsertAuthorDialogState extends ConsumerState<UpsertAuthorDialog> {
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
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add Author'),
    content: Form(
      key: _formKey,
      child: FormTextField(
        controller: _nameController,
        label: 'Name',
        hint: 'Author Name',
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
