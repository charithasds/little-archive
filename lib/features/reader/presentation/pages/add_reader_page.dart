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
import '../../domain/entities/reader_entity.dart';
import '../providers/reader_provider.dart';

class AddReaderPage extends ConsumerStatefulWidget {
  const AddReaderPage({super.key, this.existingReader});

  final ReaderEntity? existingReader;

  @override
  ConsumerState<AddReaderPage> createState() => _AddReaderPageState();
}

class _AddReaderPageState extends ConsumerState<AddReaderPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _pickedBase64Image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingReader != null) {
      final ReaderEntity reader = widget.existingReader!;
      _nameController.text = reader.name;
      _emailController.text = reader.email ?? '';
      _facebookController.text = reader.facebook ?? '';
      _phoneController.text = reader.phoneNumber ?? '';
      _pickedBase64Image = reader.image;
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

      final ReaderEntity newReader = widget.existingReader != null
          ? widget.existingReader!.copyWith(
              name: _nameController.text.trim(),
              image: _pickedBase64Image,
              email: _emailController.text.isEmpty ? null : _emailController.text.trim(),
              facebook: _facebookController.text.isEmpty ? null : _facebookController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              lastUpdated: DateTime.now(),
            )
          : ReaderEntity(
              id: FirebaseFirestore.instance.collection('readers').doc().id,
              name: _nameController.text.trim(),
              image: _pickedBase64Image,
              email: _emailController.text.isEmpty ? null : _emailController.text.trim(),
              facebook: _facebookController.text.isEmpty ? null : _facebookController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              bookIds: const <String>[],
              createdDate: DateTime.now(),
              lastUpdated: DateTime.now(),
            );

      try {
        if (widget.existingReader != null) {
          await ref.read(readerRepositoryProvider).updateReader(newReader);
        } else {
          await ref.read(readerRepositoryProvider).addReader(newReader);
        }
        if (mounted) {
          SnackBarUtils.showSuccess(
            context,
            widget.existingReader != null
                ? 'Reader updated successfully'
                : 'Reader added successfully',
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
            widget.existingReader != null ? 'Error updating reader: $e' : 'Error adding reader: $e',
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
    _emailController.dispose();
    _facebookController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingReader != null ? 'Edit Reader' : 'Add Reader'),
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
                      ? Icon(Icons.face_rounded, size: 48, color: colorScheme.onPrimaryContainer)
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
              hint: 'Reader name',
              prefixIcon: Icons.person_outline_rounded,
              maxLength: 500,
              isRequired: true,
            ),
            const SizedBox(height: 16),

            FormTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'reader@example.com',
              prefixIcon: Icons.email_outlined,
              maxLength: 200,
              keyboardType: TextInputType.emailAddress,
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
            const SizedBox(height: 16),

            FormTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '+94 77 123 4567 or 077 123 4567',
              prefixIcon: Icons.phone_outlined,
              maxLength: 20,
              keyboardType: TextInputType.phone,
              validator: Validators.validateSriLankanPhoneNumber,
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
                    : (widget.existingReader != null ? 'Update Reader' : 'Save Reader'),
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
