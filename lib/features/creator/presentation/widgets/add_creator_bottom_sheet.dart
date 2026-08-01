import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_bottom_sheet.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/loading_filled_button.dart';
import '../../domain/entities/creator_entity.dart';
import '../providers/upsert_creator_controller.dart';

class AddCreatorBottomSheet extends ConsumerStatefulWidget {
  const AddCreatorBottomSheet({super.key});

  @override
  ConsumerState<AddCreatorBottomSheet> createState() => _AddCreatorBottomSheetState();
}

class _AddCreatorBottomSheetState extends ConsumerState<AddCreatorBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upsertCreatorControllerProvider.notifier).initializeWith(null);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final CreatorEntity? savedCreator = await ref
          .read(upsertCreatorControllerProvider.notifier)
          .saveCreator(name: _nameController.text.trim());

      if (mounted) {
        if (savedCreator != null) {
          SnackBars.showSuccess('Creator added successfully');
          context.pop(savedCreator);
        } else {
          final UpsertCreatorState state = ref.read(upsertCreatorControllerProvider);

          if (state.error != null) {
            SnackBars.showError(state.error!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UpsertCreatorState state = ref.watch(upsertCreatorControllerProvider);

    return FormBottomSheet(
      title: 'Add Creator',
      actions: <Widget>[
        LoadingFilledButton(
          onPressed: _save,
          isLoading: state.isLoading,
          label: 'Save Creator',
          icon: FontAwesomeIcons.floppyDisk,
        ),
      ],
      child: Form(
        key: _formKey,
        child: FormTextField(
          controller: _nameController,
          label: 'Name',
          hint: 'Creator Name',
          prefixIcon: FontAwesomeIcons.user,
          isRequired: true,
          maxLength: 200,
          autofocus: true,
        ),
      ),
    );
  }
}
