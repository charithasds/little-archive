import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_bottom_sheet.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/loading_filled_button.dart';
import '../../domain/entities/reader_entity.dart';
import '../providers/upsert_reader_controller.dart';

class AddReaderBottomSheet extends ConsumerStatefulWidget {
  const AddReaderBottomSheet({super.key});

  @override
  ConsumerState<AddReaderBottomSheet> createState() => _AddReaderBottomSheetState();
}

class _AddReaderBottomSheetState extends ConsumerState<AddReaderBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upsertReaderControllerProvider.notifier).initializeWith(null);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final ReaderEntity? savedReader = await ref
          .read(upsertReaderControllerProvider.notifier)
          .saveReader(name: _nameController.text.trim());

      if (mounted) {
        if (savedReader != null) {
          SnackBars.showSuccess('Reader added successfully');
          context.pop(savedReader);
        } else {
          final UpsertReaderState state = ref.read(upsertReaderControllerProvider);

          if (state.error != null) {
            SnackBars.showError(state.error!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UpsertReaderState state = ref.watch(upsertReaderControllerProvider);

    return FormBottomSheet(
      title: 'Add Reader',
      actions: <Widget>[
        LoadingFilledButton(
          onPressed: _save,
          isLoading: state.isLoading,
          label: 'Save Reader',
          icon: Icons.save_rounded,
        ),
      ],
      child: Form(
        key: _formKey,
        child: FormTextField(
          controller: _nameController,
          label: 'Name',
          hint: 'Reader Name',
          prefixIcon: Icons.face_rounded,
          isRequired: true,
          maxLength: 200,
          autofocus: true,
        ),
      ),
    );
  }
}
