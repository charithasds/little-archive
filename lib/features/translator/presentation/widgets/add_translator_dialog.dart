import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/translator_entity.dart';
import '../providers/translator_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTranslatorDialog extends ConsumerStatefulWidget {
  const AddTranslatorDialog({super.key});

  @override
  ConsumerState<AddTranslatorDialog> createState() =>
      _AddTranslatorDialogState();
}

class _AddTranslatorDialogState extends ConsumerState<AddTranslatorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authStateProvider).value;
      if (user == null) return;

      final newTranslator = TranslatorEntity(
        id: FirebaseFirestore.instance.collection('translators').doc().id,
        userId: user.uid,
        name: _nameController.text.trim(),
        bookIds: [],
        workIds: [],
        createdDate: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      try {
        await ref
            .read(translatorRepositoryProvider)
            .addTranslator(newTranslator);
        if (mounted) {
          Navigator.of(context).pop(newTranslator);
        }
      } on NoConnectionException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding translator: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Translator'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Add')),
      ],
    );
  }
}
