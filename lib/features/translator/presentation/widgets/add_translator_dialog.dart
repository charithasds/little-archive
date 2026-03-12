import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/snackbar_utils.dart';
import '../../domain/entities/translator_entity.dart';
import '../../domain/repositories/translator_repository.dart';
import '../providers/translator_provider.dart';

class AddTranslatorDialog extends ConsumerStatefulWidget {
  const AddTranslatorDialog({super.key});

  @override
  ConsumerState<AddTranslatorDialog> createState() => _AddTranslatorDialogState();
}

class _AddTranslatorDialogState extends ConsumerState<AddTranslatorDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final UserEntity? user = ref.read(authStateProvider).value;
      if (user == null) {
        return;
      }

      final TranslatorEntity newTranslator = TranslatorEntity(
        id: FirebaseFirestore.instance.collection('translators').doc().id,
        name: _nameController.text.trim(),
        bookIds: const <String>[],
        workIds: const <String>[],
        createdDate: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      try {
        await ref
            .read<TranslatorRepository>(translatorRepositoryProvider)
            .addTranslator(newTranslator);
        if (mounted) {
          SnackBarUtils.showSuccess(context, 'Translator added successfully');
          Navigator.of(context).pop(newTranslator);
        }
      } on NoConnectionException catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, e.message);
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, 'Error adding translator: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add Translator'),
    content: Form(
      key: _formKey,
      child: FormTextField(
        controller: _nameController,
        label: 'Name',
        hint: 'Translator Name',
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
