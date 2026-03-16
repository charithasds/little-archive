import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/domain/validators.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/snackbar_utils.dart';
import '../../domain/entities/author_entity.dart';
import '../providers/author_provider.dart';

class AddAuthorPage extends ConsumerStatefulWidget {
  const AddAuthorPage({super.key, this.existingAuthor});

  final AuthorEntity? existingAuthor;

  @override
  ConsumerState<AddAuthorPage> createState() => _AddAuthorPageState();
}

class _AddAuthorPageState extends ConsumerState<AddAuthorPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _otherNameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();

  String? _pickedBase64Image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingAuthor != null) {
      final AuthorEntity author = widget.existingAuthor!;
      _nameController.text = author.name;
      _otherNameController.text = author.otherName ?? '';
      _websiteController.text = author.website ?? '';
      _facebookController.text = author.facebook ?? '';
      _pickedBase64Image = author.image;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        _pickedBase64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final UserEntity? user = ref.read(authStateProvider).value;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final AuthorEntity newAuthor = widget.existingAuthor != null
          ? widget.existingAuthor!.copyWith(
              name: _nameController.text.trim(),
              otherName: _otherNameController.text.isEmpty
                  ? null
                  : _otherNameController.text.trim(),
              website: _websiteController.text.isEmpty ? null : _websiteController.text.trim(),
              facebook: _facebookController.text.isEmpty ? null : _facebookController.text.trim(),
              image: _pickedBase64Image,
              lastUpdated: DateTime.now(),
            )
          : AuthorEntity(
              id: FirebaseFirestore.instance.collection('authors').doc().id,
              name: _nameController.text.trim(),
              otherName: _otherNameController.text.isEmpty
                  ? null
                  : _otherNameController.text.trim(),
              website: _websiteController.text.isEmpty ? null : _websiteController.text.trim(),
              facebook: _facebookController.text.isEmpty ? null : _facebookController.text.trim(),
              image: _pickedBase64Image,
              bookIds: const <String>[],
              workIds: const <String>[],
              createdDate: DateTime.now(),
              lastUpdated: DateTime.now(),
            );

      try {
        if (widget.existingAuthor != null) {
          await ref.read(authorRepositoryProvider).updateAuthor(newAuthor);
        } else {
          await ref.read(authorRepositoryProvider).addAuthor(newAuthor);
        }
        if (mounted) {
          SnackBarUtils.showSuccess(
            context,
            widget.existingAuthor != null
                ? 'Author updated successfully'
                : 'Author added successfully',
          );
          Navigator.of(context).pop();
        }
      } on NoConnectionException catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, e.message);
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showError(
            context,
            widget.existingAuthor != null ? 'Error updating author: $e' : 'Error adding author: $e',
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _otherNameController.dispose();
    _websiteController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingAuthor != null ? 'Edit Author' : 'Add Author'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primaryContainer,
                    border: Border.all(color: colorScheme.primary, width: 3),
                    image: _pickedBase64Image != null
                        ? DecorationImage(
                            image: MemoryImage(base64Decode(_pickedBase64Image!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _pickedBase64Image == null
                      ? Icon(Icons.person_rounded, size: 56, color: colorScheme.onPrimaryContainer)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(_pickedBase64Image == null ? 'Add Image' : 'Change Photo'),
              ),
            ),
            const SizedBox(height: 24),

            FormTextField(
              controller: _nameController,
              label: 'Name',
              hint: 'Author name',
              prefixIcon: Icons.person_outline_rounded,
              maxLength: 500,
              isRequired: true,
            ),
            const SizedBox(height: 16),

            FormTextField(
              controller: _otherNameController,
              label: 'Other Name',
              hint: 'Alternative Name',
              prefixIcon: Icons.badge_outlined,
              maxLength: 500,
            ),
            const SizedBox(height: 16),

            FormTextField(
              controller: _websiteController,
              label: 'Website',
              hint: 'https://www.example.com',
              prefixIcon: Icons.language_rounded,
              maxLength: 200,
              keyboardType: TextInputType.url,
              validator: Validators.validateWebsiteUrl,
            ),
            const SizedBox(height: 16),

            FormTextField(
              controller: _facebookController,
              label: 'Facebook',
              hint: 'https://www.facebook.com/username',
              prefixIcon: Icons.facebook_rounded,
              maxLength: 200,
              keyboardType: TextInputType.url,
              validator: Validators.validateFacebookUrl,
            ),
            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _isLoading ? null : _save,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(
                _isLoading
                    ? 'Saving...'
                    : (widget.existingAuthor != null ? 'Update Author' : 'Save Author'),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
