import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/utils/validators.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/translator_entity.dart';
import '../providers/upsert_translator_controller.dart';

class UpsertTranslatorPage extends ConsumerStatefulWidget {
  const UpsertTranslatorPage({super.key, this.existingTranslator});

  final TranslatorEntity? existingTranslator;

  @override
  ConsumerState<UpsertTranslatorPage> createState() => _UpsertTranslatorPageState();
}

class _UpsertTranslatorPageState extends ConsumerState<UpsertTranslatorPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _otherNameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingTranslator != null) {
      final TranslatorEntity translator = widget.existingTranslator!;
      _nameController.text = translator.name;
      _otherNameController.text = translator.otherName ?? '';
      _websiteController.text = translator.website ?? '';
      _facebookController.text = translator.facebook ?? '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(upsertTranslatorControllerProvider.notifier)
          .initializeWith(widget.existingTranslator);
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final TranslatorEntity? savedTranslator = await ref
          .read(upsertTranslatorControllerProvider.notifier)
          .saveTranslator(
            existingTranslator: widget.existingTranslator,
            name: _nameController.text.trim(),
            otherName: _otherNameController.text.trim(),
            website: _websiteController.text.trim(),
            facebook: _facebookController.text.trim(),
          );

      final bool isSuccess = savedTranslator != null;

      if (isSuccess && mounted) {
        SnackBars.showSuccess(
          context,
          widget.existingTranslator != null
              ? 'Translator updated successfully'
              : 'Translator added successfully',
        );
        Navigator.of(context).pop();
      } else if (!isSuccess && mounted) {
        final UpsertTranslatorState state = ref.read(upsertTranslatorControllerProvider);
        if (state.error != null) {
          SnackBars.showError(context, state.error!);
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
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final UpsertTranslatorState state = ref.watch(upsertTranslatorControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTranslator != null ? 'Edit Translator' : 'Add Translator'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            Center(
              child: GestureDetector(
                onTap: () => ref.read(upsertTranslatorControllerProvider.notifier).pickImage(),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primaryContainer,
                    border: Border.all(color: colorScheme.primary, width: 3),
                    image: state.pickedBase64Image != null
                        ? DecorationImage(
                            image: MemoryImage(base64Decode(state.pickedBase64Image!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: state.pickedBase64Image == null
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
                onPressed: () => ref.read(upsertTranslatorControllerProvider.notifier).pickImage(),
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(state.pickedBase64Image == null ? 'Add Image' : 'Change Photo'),
              ),
            ),
            const SizedBox(height: 24),

            FormTextField(
              controller: _nameController,
              label: 'Name',
              hint: 'Translator name',
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
              onPressed: state.isLoading ? null : _save,
              icon: state.isLoading
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
                state.isLoading
                    ? 'Saving...'
                    : (widget.existingTranslator != null ? 'Update Translator' : 'Save Translator'),
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
