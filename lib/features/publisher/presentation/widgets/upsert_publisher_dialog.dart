import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../domain/entities/publisher_entity.dart';
import '../providers/upsert_publisher_controller.dart';

class UpsertPublisherDialog extends ConsumerStatefulWidget {
  const UpsertPublisherDialog({super.key});

  @override
  ConsumerState<UpsertPublisherDialog> createState() => _UpsertPublisherDialogState();
}

class _UpsertPublisherDialogState extends ConsumerState<UpsertPublisherDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final PublisherEntity? savedPublisher = await ref
          .read(upsertPublisherControllerProvider.notifier)
          .savePublisher(
            existingPublisher: null,
            name: _nameController.text.trim(),
            otherName: '',
            website: '',
            email: '',
            facebook: '',
            phone: '',
          );

      if (mounted) {
        if (savedPublisher != null) {
          SnackBars.showSuccess(context, 'Publisher added successfully');
          Navigator.of(context).pop(savedPublisher);
        } else {
          final UpsertPublisherState state = ref.read(upsertPublisherControllerProvider);
          if (state.error != null) {
            SnackBars.showError(context, state.error!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add Publisher'),
    content: Form(
      key: _formKey,
      child: FormTextField(
        controller: _nameController,
        label: 'Name',
        hint: 'Publisher Name',
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
