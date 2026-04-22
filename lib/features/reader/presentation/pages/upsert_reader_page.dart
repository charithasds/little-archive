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
import '../../domain/entities/reader_entity.dart';
import '../providers/upsert_reader_controller.dart';

class UpsertReaderPage extends ConsumerStatefulWidget {
  const UpsertReaderPage({super.key, this.existingReader});

  final ReaderEntity? existingReader;

  @override
  ConsumerState<UpsertReaderPage> createState() => _UpsertReaderPageState();
}

class _UpsertReaderPageState extends ConsumerState<UpsertReaderPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _otherNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upsertReaderControllerProvider.notifier).initializeWith(widget.existingReader);
    });
    if (widget.existingReader != null) {
      final ReaderEntity reader = widget.existingReader!;
      _nameController.text = reader.name;
      _otherNameController.text = reader.otherName ?? '';
      _emailController.text = reader.email ?? '';
      _facebookController.text = reader.facebook ?? '';
      _phoneController.text = reader.phoneNumber ?? '';
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final ReaderEntity? savedReader = await ref
          .read(upsertReaderControllerProvider.notifier)
          .saveReader(
            name: _nameController.text.trim(),
            otherName: _otherNameController.text.trim(),
            email: _emailController.text.trim(),
            facebook: _facebookController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
          );

      if (savedReader != null && mounted) {
        SnackBars.showSuccess(
          widget.existingReader != null
              ? 'Reader updated successfully'
              : 'Reader added successfully',
        );
        context.pop();
      } else if (savedReader == null && mounted) {
        final UpsertReaderState state = ref.read(upsertReaderControllerProvider);
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
    _emailController.dispose();
    _facebookController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final UpsertReaderState state = ref.watch(upsertReaderControllerProvider);

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
                onTap: () => ref.read(upsertReaderControllerProvider.notifier).pickImage(),
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
                      ? Icon(Icons.face_rounded, size: 56, color: Images.getPickerIconColor(theme))
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
                    onPressed: () => ref.read(upsertReaderControllerProvider.notifier).pickImage(),
                    icon: const Icon(Icons.camera_rounded),
                    label: Text(state.pickedBase64Image == null ? 'Add Image' : 'Change Image'),
                  ),
                  if (state.pickedBase64Image != null)
                    TextButton.icon(
                      onPressed: () =>
                          ref.read(upsertReaderControllerProvider.notifier).clearImage(),
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
                  hint: 'Reader Name',
                  prefixIcon: Icons.face_rounded,
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
              title: 'Contact',
              icon: Icons.contact_support_outlined,
              children: <Widget>[
                FormTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'reader@example.com',
                  prefixIcon: Icons.email_rounded,
                  maxLength: 200,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
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
                  prefixIcon: Icons.phone_rounded,
                  maxLength: 20,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validateSriLankanPhoneNumber,
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
                    : (widget.existingReader != null ? 'Update Reader' : 'Save Reader'),
              ),
              style: Buttons.getPrimaryFilledButtonStyle(theme),
            ),
          ],
        ),
      ),
    );
  }
}
