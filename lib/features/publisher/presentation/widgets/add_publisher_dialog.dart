import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/presentation/widgets/snackbar_utils.dart';
import '../../domain/entities/publisher_entity.dart';
import '../../domain/repositories/publisher_repository.dart';
import '../providers/publisher_provider.dart';

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
      final UserEntity? user = ref.read<AsyncValue<UserEntity?>>(authStateProvider).value;
      if (user == null) {
        return;
      }

      final PublisherEntity newPublisher = PublisherEntity(
        id: FirebaseFirestore.instance.collection('publishers').doc().id,
        userId: user.uid,
        name: _nameController.text.trim(),
        bookIds: const <String>[],
        createdDate: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      try {
        await ref.read<PublisherRepository>(publisherRepositoryProvider).addPublisher(newPublisher);
        if (mounted) {
          SnackBarUtils.showSuccess(context, 'Publisher added successfully');
          Navigator.of(context).pop(newPublisher);
        }
      } on NoConnectionException catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, e.message);
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, 'Error adding publisher: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add Publisher'),
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
