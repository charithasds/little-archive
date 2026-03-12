import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/snackbar_utils.dart';
import '../../domain/entities/reader_entity.dart';
import '../../domain/repositories/reader_repository.dart';
import '../providers/reader_provider.dart';

class AddReaderDialog extends ConsumerStatefulWidget {
  const AddReaderDialog({super.key});

  @override
  ConsumerState<AddReaderDialog> createState() => _AddReaderDialogState();
}

class _AddReaderDialogState extends ConsumerState<AddReaderDialog> {
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

      final ReaderEntity newReader = ReaderEntity(
        id: FirebaseFirestore.instance.collection('readers').doc().id,

        name: _nameController.text.trim(),
        bookIds: const <String>[],
        createdDate: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      try {
        await ref.read<ReaderRepository>(readerRepositoryProvider).addReader(newReader);
        if (mounted) {
          SnackBarUtils.showSuccess(context, 'Reader added successfully');
          Navigator.of(context).pop(newReader);
        }
      } on NoConnectionException catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, e.message);
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, 'Error adding reader: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add Reader'),
    content: Form(
      key: _formKey,
      child: FormTextField(
        controller: _nameController,
        label: 'Name',
        hint: 'Reader Name',
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
