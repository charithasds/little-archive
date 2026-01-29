import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/translator_entity.dart';
import '../providers/translator_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AddTranslatorPage extends ConsumerStatefulWidget {
  const AddTranslatorPage({super.key});

  @override
  ConsumerState<AddTranslatorPage> createState() => _AddTranslatorPageState();
}

class _AddTranslatorPageState extends ConsumerState<AddTranslatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _otherNameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _facebookController = TextEditingController();

  String? _pickedBase64Image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _pickedBase64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = ref.read(authStateProvider).value;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final newTranslator = TranslatorEntity(
        id: FirebaseFirestore.instance.collection('translators').doc().id,
        userId: user.uid,
        name: _nameController.text.trim(),
        otherName: _otherNameController.text.isEmpty
            ? null
            : _otherNameController.text.trim(),
        website: _websiteController.text.isEmpty
            ? null
            : _websiteController.text.trim(),
        facebook: _facebookController.text.isEmpty
            ? null
            : _facebookController.text.trim(),
        image: _pickedBase64Image,
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
          Navigator.of(context).pop();
        }
      } on NoConnectionException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding translator: $e'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Translator'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Profile Image Picker
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
                            image: MemoryImage(
                              base64Decode(_pickedBase64Image!),
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _pickedBase64Image == null
                      ? Icon(
                          Icons.translate_rounded,
                          size: 56,
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
                label: Text(
                  _pickedBase64Image == null ? 'Add Photo' : 'Change Photo',
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter translator name',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
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
                  borderSide: BorderSide(color: colorScheme.error, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.error, width: 2),
                ),
              ),
              maxLength: 500,
              validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _otherNameController,
              decoration: InputDecoration(
                labelText: 'Other Name',
                hintText: 'Pen name or alias (optional)',
                prefixIcon: const Icon(Icons.badge_outlined),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
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
                hintText: 'https://example.com',
                prefixIcon: const Icon(Icons.language_rounded),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
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
                  borderSide: BorderSide(color: colorScheme.error, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.error, width: 2),
                ),
              ),
              maxLength: 200,
              keyboardType: TextInputType.url,
              validator: Validators.validateWebsiteUrl,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _facebookController,
              decoration: InputDecoration(
                labelText: 'Facebook',
                hintText: 'https://facebook.com/username',
                prefixIcon: const Icon(Icons.facebook_rounded),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
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
                  borderSide: BorderSide(color: colorScheme.error, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.error, width: 2),
                ),
              ),
              maxLength: 200,
              keyboardType: TextInputType.url,
              validator: Validators.validateFacebookUrl,
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
              label: Text(_isLoading ? 'Saving...' : 'Save Translator'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
