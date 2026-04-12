import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/utils/button_styles.dart';
import '../../../../core/shared/presentation/utils/image_styles.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/utils/validators.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/publisher_entity.dart';
import '../providers/upsert_publisher_controller.dart';

class UpsertPublisherPage extends ConsumerStatefulWidget {
  const UpsertPublisherPage({super.key, this.existingPublisher});

  final PublisherEntity? existingPublisher;

  @override
  ConsumerState<UpsertPublisherPage> createState() => _UpsertPublisherPageState();
}

class _UpsertPublisherPageState extends ConsumerState<UpsertPublisherPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _otherNameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upsertPublisherControllerProvider.notifier).initializeWith(widget.existingPublisher);
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final PublisherEntity? savedPublisher = await ref
          .read(upsertPublisherControllerProvider.notifier)
          .savePublisher(
            existingPublisher: widget.existingPublisher,
            name: _nameController.text.trim(),
            otherName: _otherNameController.text.trim(),
            website: _websiteController.text.trim(),
            email: _emailController.text.trim(),
            facebook: _facebookController.text.trim(),
            phone: _phoneController.text.trim(),
          );

      final bool isSuccess = savedPublisher != null;

      if (isSuccess && mounted) {
        SnackBars.showSuccess(
          context,
          widget.existingPublisher != null
              ? 'Publisher updated successfully'
              : 'Publisher added successfully',
        );
        Navigator.of(context).pop();
      } else if (!isSuccess && mounted) {
        final UpsertPublisherState state = ref.read(upsertPublisherControllerProvider);
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
    _emailController.dispose();
    _facebookController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final UpsertPublisherState state = ref.watch(upsertPublisherControllerProvider);

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
                onTap: () => ref.read(upsertPublisherControllerProvider.notifier).pickImage(),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: ImageStyles.getPickerDecoration(
                    theme,
                    image: state.pickedBase64Logo != null
                        ? DecorationImage(
                            image: MemoryImage(base64Decode(state.pickedBase64Logo!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: state.pickedBase64Logo == null
                      ? Icon(
                          Icons.business_rounded,
                          size: 48,
                          color: ImageStyles.getPickerIconColor(theme),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => ref.read(upsertPublisherControllerProvider.notifier).pickImage(),
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(state.pickedBase64Logo == null ? 'Add Logo' : 'Change Logo'),
              ),
            ),
            const SizedBox(height: 24),

            FormTextField(
              controller: _nameController,
              label: 'Name',
              hint: 'Publisher Name',
              prefixIcon: Icons.business_outlined,
              maxLength: 200,
              isRequired: true,
            ),
            const SizedBox(height: 16),

            FormTextField(
              controller: _otherNameController,
              label: 'Other Name',
              hint: 'Alternative Name',
              prefixIcon: Icons.badge_outlined,
              maxLength: 200,
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
              prefixIcon: Icons.phone_outlined,
              maxLength: 50,
              keyboardType: TextInputType.phone,
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
                    : (widget.existingPublisher != null ? 'Update Publisher' : 'Save Publisher'),
              ),
              style: ButtonStyles.getPrimaryFilledButtonStyle(theme),
            ),
          ],
        ),
      ),
    );
  }
}
