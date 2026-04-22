import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/utils/validators.dart';
import '../../../../core/shared/presentation/widgets/form_section.dart';
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
            name: _nameController.text.trim(),
            otherName: _otherNameController.text.trim(),
            website: _websiteController.text.trim(),
            facebook: _facebookController.text.trim(),
          );

      final bool isSuccess = savedTranslator != null;

      if (isSuccess && mounted) {
        SnackBars.showSuccess(
          widget.existingTranslator != null
              ? 'Translator updated successfully'
              : 'Translator added successfully',
        );
        context.pop();
      } else if (!isSuccess && mounted) {
        final UpsertTranslatorState state = ref.read(upsertTranslatorControllerProvider);
        if (state.error != null) {
          SnackBars.showError(state.error!);
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
                  decoration: Images.getPickerDecoration(
                    theme,
                    image: state.pickedBase64Image != null
                        ? DecorationImage(
                            image: Images.getImageProvider(state.pickedBase64Image),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: state.pickedBase64Image == null
                      ? Icon(
                          Icons.translate_rounded,
                          size: 56,
                          color: Images.getPickerIconColor(theme),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Wrap(
                spacing: 12,
                children: <Widget>[
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(upsertTranslatorControllerProvider.notifier).pickImage(),
                    icon: const Icon(Icons.camera_rounded),
                    label: Text(state.pickedBase64Image == null ? 'Add Image' : 'Change Image'),
                  ),
                  if (state.pickedBase64Image != null)
                    TextButton.icon(
                      onPressed: () =>
                          ref.read(upsertTranslatorControllerProvider.notifier).clearImage(),
                      icon: const Icon(Icons.delete_rounded),
                      label: const Text('Remove Image'),
                      style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),


            FormSection(
              title: 'Identity',
              icon: Icons.person_outline_rounded,
              children: <Widget>[
                FormTextField(
                  controller: _nameController,
                  label: 'Name',
                  hint: 'Translator Name',
                  prefixIcon: Icons.translate_rounded,
                  maxLength: 200,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                FormTextField(
                  controller: _otherNameController,
                  label: 'Other Name',
                  hint: 'Alternative Name',
                  prefixIcon: Icons.badge_rounded,
                  maxLength: 200,
                ),
              ],
            ),

            FormSection(
              title: 'Online Presence',
              icon: Icons.public_rounded,
              children: <Widget>[
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
              ],
            ),

            const SizedBox(height: 16),

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
              style: Buttons.getPrimaryFilledButtonStyle(theme),
            ),
          ],
        ),
      ),
    );
  }
}
