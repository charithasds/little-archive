import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/publisher_entity.dart';
import '../providers/publisher_provider.dart';

class AddPublisherPage extends ConsumerStatefulWidget {
  const AddPublisherPage({super.key});

  @override
  ConsumerState<AddPublisherPage> createState() => _AddPublisherPageState();
}

class _AddPublisherPageState extends ConsumerState<AddPublisherPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _otherNameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _pickedBase64Logo;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        _pickedBase64Logo = base64Encode(bytes);
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

      final PublisherEntity newPublisher = PublisherEntity(
        id: FirebaseFirestore.instance.collection('publishers').doc().id,
        userId: user.uid,
        name: _nameController.text.trim(),
        otherName: _otherNameController.text.isEmpty ? null : _otherNameController.text.trim(),
        logo: _pickedBase64Logo,
        website: _websiteController.text.isEmpty ? null : _websiteController.text.trim(),
        email: _emailController.text.isEmpty ? null : _emailController.text.trim(),
        facebook: _facebookController.text.isEmpty ? null : _facebookController.text.trim(),
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text.trim(),
        bookIds: const <String>[],
        createdDate: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      try {
        await ref.read(publisherRepositoryProvider).addPublisher(newPublisher);
        if (mounted) {
          SnackBarUtils.showSuccess(context, 'Publisher added successfully');
          Navigator.of(context).pop();
        }
      } on NoConnectionException catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, e.message);
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, 'Error adding publisher: $e');
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
    _emailController.dispose();
    _facebookController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Publisher'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            // Logo Picker
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
                    image: _pickedBase64Logo != null
                        ? DecorationImage(
                            image: MemoryImage(base64Decode(_pickedBase64Logo!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _pickedBase64Logo == null
                      ? Icon(
                          Icons.business_rounded,
                          size: 48,
                          color: colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(_pickedBase64Logo == null ? 'Add Logo' : 'Change Logo'),
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Publisher name',
                prefixIcon: const Icon(Icons.business_outlined),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.error),
                ),
              ),
              maxLength: 500,
              validator: (String? v) => v!.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _otherNameController,
              decoration: InputDecoration(
                labelText: 'Other Name',
                hintText: 'Alternative name',
                prefixIcon: const Icon(Icons.badge_outlined),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
              maxLength: 500,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _websiteController,
              decoration: InputDecoration(
                labelText: 'Website',
                hintText: 'https://www.example.com',
                prefixIcon: const Icon(Icons.language_rounded),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.error),
                ),
              ),
              maxLength: 200,
              validator: Validators.validateWebsiteUrl,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'publisher@example.com',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
              maxLength: 200,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _facebookController,
              decoration: InputDecoration(
                labelText: 'Facebook',
                hintText: 'https://www.facebook.com/username',
                prefixIcon: const Icon(Icons.facebook_rounded),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.error),
                ),
              ),
              maxLength: 200,
              validator: Validators.validateFacebookUrl,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+94 77 123 4567 or 077 123 4567',
                prefixIcon: const Icon(Icons.phone_outlined),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 50,
            ),
            const SizedBox(height: 32),

            // Save Button
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
              label: Text(_isLoading ? 'Saving...' : 'Save Publisher'),
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
