import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/publisher_entity.dart';
import '../providers/upsert_publisher_controller.dart';

class AddPublisherDialog extends ConsumerStatefulWidget {
  const AddPublisherDialog({super.key});

  @override
  ConsumerState<AddPublisherDialog> createState() => _AddPublisherDialogState();
}

class _AddPublisherDialogState extends ConsumerState<AddPublisherDialog> {
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
          .savePublisher(existingPublisher: null, name: _nameController.text.trim());

      if (mounted) {
        if (savedPublisher != null) {
          SnackBars.showSuccess('Publisher added successfully');
          context.pop(savedPublisher);
        } else {
          final UpsertPublisherState state = ref.read(upsertPublisherControllerProvider);

          if (state.error != null) {
            SnackBars.showError(state.error!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final UpsertPublisherState state = ref.watch(upsertPublisherControllerProvider);

    return AlertDialog(
      title: const Text('Add Publisher'),
      content: Form(
        key: _formKey,
        child: FormTextField(
          controller: _nameController,
          label: 'Name',
          hint: 'Publisher Name',
          prefixIcon: Icons.business_rounded,
          isRequired: true,
          maxLength: 200,
          autofocus: true,
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: state.isLoading ? null : _save,
          style: Buttons.getPrimaryFilledButtonStyle(
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
