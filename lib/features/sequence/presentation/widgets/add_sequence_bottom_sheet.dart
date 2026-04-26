import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_bottom_sheet.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/loading_filled_button.dart';
import '../../domain/entities/sequence_entity.dart';
import '../providers/upsert_sequence_controller.dart';

class AddSequenceBottomSheet extends ConsumerStatefulWidget {
  const AddSequenceBottomSheet({super.key});

  @override
  ConsumerState<AddSequenceBottomSheet> createState() => _AddSequenceBottomSheetState();
}

class _AddSequenceBottomSheetState extends ConsumerState<AddSequenceBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upsertSequenceControllerProvider.notifier).initializeWith(null);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final SequenceEntity? savedSequence = await ref
          .read(upsertSequenceControllerProvider.notifier)
          .saveSequence(name: _nameController.text.trim());

      if (mounted) {
        if (savedSequence != null) {
          SnackBars.showSuccess('Sequence added successfully');
          context.pop(savedSequence);
        } else {
          final UpsertSequenceState state = ref.read(upsertSequenceControllerProvider);

          if (state.error != null) {
            SnackBars.showError(state.error!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UpsertSequenceState state = ref.watch(upsertSequenceControllerProvider);

    return FormBottomSheet(
      title: 'Add Sequence',
      actions: <Widget>[
        LoadingFilledButton(
          onPressed: _save,
          isLoading: state.isLoading,
          label: 'Save Sequence',
          icon: Icons.save_rounded,
        ),
      ],
      child: Form(
        key: _formKey,
        child: FormTextField(
          controller: _nameController,
          label: 'Name',
          hint: 'Sequence Name',
          prefixIcon: Icons.layers_rounded,
          isRequired: true,
          maxLength: 200,
          autofocus: true,
        ),
      ),
    );
  }
}
