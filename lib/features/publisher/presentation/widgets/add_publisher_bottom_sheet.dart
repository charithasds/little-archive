import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_bottom_sheet.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/loading_filled_button.dart';
import '../../domain/entities/publisher_entity.dart';
import '../providers/upsert_publisher_controller.dart';

class AddPublisherBottomSheet extends ConsumerStatefulWidget {
  const AddPublisherBottomSheet({super.key});

  @override
  ConsumerState<AddPublisherBottomSheet> createState() => _AddPublisherBottomSheetState();
}

class _AddPublisherBottomSheetState extends ConsumerState<AddPublisherBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upsertPublisherControllerProvider.notifier).initializeWith(null);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final PublisherEntity? savedPublisher = await ref
          .read(upsertPublisherControllerProvider.notifier)
          .savePublisher(name: _nameController.text.trim());

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
    final UpsertPublisherState state = ref.watch(upsertPublisherControllerProvider);

    return FormBottomSheet(
      title: 'Add Publisher',
      actions: <Widget>[
        LoadingFilledButton(
          onPressed: _save,
          isLoading: state.isLoading,
          label: 'Save Publisher',
          icon: Icons.save_rounded,
        ),
      ],
      child: Form(
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
    );
  }
}
