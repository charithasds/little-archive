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
import '../../domain/entities/publisher_entity.dart';
import '../providers/publisher_provider.dart';

class AddPublisherPage extends ConsumerStatefulWidget {
  const AddPublisherPage({super.key, this.existingPublisher});

  final PublisherEntity? existingPublisher;

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

  @override
  void initState() {
    super.initState();
    if (widget.existingPublisher != null) {
      final PublisherEntity publisher = widget.existingPublisher!;
      _nameController.text = publisher.name;
      _otherNameController.text = publisher.otherName ?? '';
      _websiteController.text = publisher.website ?? '';
      _emailController.text = publisher.email ?? '';
      _facebookController.text = publisher.facebook ?? '';
      _phoneController.text = publisher.phoneNumber ?? '';
      _pickedBase64Logo = publisher.logo;
    }
  }

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

      final PublisherEntity newPublisher = widget.existingPublisher != null
          ? widget.existingPublisher!.copyWith(
              name: _nameController.text.trim(),
              otherName: _otherNameController.text.isEmpty
                  ? null
                  : _otherNameController.text.trim(),
              logo: _pickedBase64Logo,
              website: _websiteController.text.isEmpty ? null : _websiteController.text.trim(),
              email: _emailController.text.isEmpty ? null : _emailController.text.trim(),
              facebook: _facebookController.text.isEmpty ? null : _facebookController.text.trim(),
              phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text.trim(),
              lastUpdated: DateTime.now(),
            )
          : PublisherEntity(
              id: FirebaseFirestore.instance.collection('publishers').doc().id,
              name: _nameController.text.trim(),
              otherName: _otherNameController.text.isEmpty
                  ? null
                  : _otherNameController.text.trim(),
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
        if (widget.existingPublisher != null) {
          await ref.read(publisherRepositoryProvider).updatePublisher(newPublisher);
        } else {
          await ref.read(publisherRepositoryProvider).addPublisher(newPublisher);
        }
        if (mounted) {
          SnackBarUtils.showSuccess(
            context,
            widget.existingPublisher != null
                ? 'Publisher updated successfully'
                : 'Publisher added successfully',
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
            widget.existingPublisher != null
                ? 'Error updating publisher: $e'
                : 'Error adding publisher: $e',
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
        title: Text(widget.existingPublisher != null ? 'Edit Publisher' : 'Add Publisher'),
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

            FormTextField(
              controller: _nameController,
              label: 'Name',
              hint: 'Publisher name',
              prefixIcon: Icons.business_outlined,
              maxLength: 500,
              isRequired: true,
            ),
            const SizedBox(height: 16),

            FormTextField(
              controller: _otherNameController,
              label: 'Other Name',
              hint: 'Alternative name',
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
              controller: _emailController,
              label: 'Email',
              hint: 'publisher@example.com',
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
              maxLength: 50,
              keyboardType: TextInputType.phone,
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
                    : (widget.existingPublisher != null ? 'Update Publisher' : 'Save Publisher'),
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
