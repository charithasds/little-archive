import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_bottom_sheet.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/loading_filled_button.dart';
import '../../domain/entities/translator_entity.dart';
import '../providers/upsert_translator_controller.dart';

class AddTranslatorBottomSheet extends ConsumerStatefulWidget {
  const AddTranslatorBottomSheet({super.key});

  @override
  ConsumerState<AddTranslatorBottomSheet> createState() => _AddTranslatorBottomSheetState();
}

class _AddTranslatorBottomSheetState extends ConsumerState<AddTranslatorBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upsertTranslatorControllerProvider.notifier).initializeWith(null);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final TranslatorEntity? savedTranslator =
          await ref.read(upsertTranslatorControllerProvider.notifier).saveTranslator(
            name: _nameController.text.trim(),
          );

      if (mounted) {
        if (savedTranslator != null) {
          SnackBars.showSuccess('Translator added successfully');
          context.pop(savedTranslator);
        } else {
          final UpsertTranslatorState state = ref.read(upsertTranslatorControllerProvider);

          if (state.error != null) {
            SnackBars.showError(state.error!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UpsertTranslatorState state = ref.watch(upsertTranslatorControllerProvider);

    return FormBottomSheet(
      title: 'Add Translator',
      actions: <Widget>[
        LoadingFilledButton(
          onPressed: _save,
          isLoading: state.isLoading,
          label: 'Save Translator',
          icon: Icons.save_rounded,
        ),
      ],
      child: Form(
        key: _formKey,
        child: FormTextField(
          controller: _nameController,
          label: 'Name',
          hint: 'Translator Name',
          prefixIcon: Icons.translate_rounded,
          isRequired: true,
          maxLength: 200,
          autofocus: true,
        ),
      ),
    );
  }
}
