import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/author_entity.dart';
import '../../domain/repositories/author_repository.dart';
import '../providers/author_provider.dart';

class AddAuthorDialog extends ConsumerStatefulWidget {
  const AddAuthorDialog({super.key});

  @override
  ConsumerState<AddAuthorDialog> createState() => _AddAuthorDialogState();
}

class _AddAuthorDialogState extends ConsumerState<AddAuthorDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final UserEntity? user = ref.read<AsyncValue<UserEntity?>>(authStateProvider).value;
      if (user == null) {
        return;
      }

      final AuthorEntity newAuthor = AuthorEntity(
        id: FirebaseFirestore.instance.collection('authors').doc().id,
        userId: user.uid,
        name: _nameController.text.trim(),
        bookIds: const <String>[],
        workIds: const <String>[],
        createdDate: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      try {
        await ref.read<AuthorRepository>(authorRepositoryProvider).addAuthor(newAuthor);
        if (mounted) {
          SnackBarUtils.showSuccess(context, 'Author added successfully');
          Navigator.of(context).pop(newAuthor);
        }
      } on NoConnectionException catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, e.message);
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, 'Error adding author: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Author'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          validator: (String? value) => value == null || value.isEmpty ? 'Name is required' : null,
          maxLength: 500,
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Add')),
      ],
    );
  }
}
