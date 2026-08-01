import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/utils/validators.dart';
import '../../../../core/shared/presentation/widgets/form_section.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/creator_entity.dart';
import '../providers/upsert_creator_controller.dart';

class UpsertCreatorPage extends ConsumerStatefulWidget {
  const UpsertCreatorPage({super.key, this.existingCreator});

  final CreatorEntity? existingCreator;

  @override
  ConsumerState<UpsertCreatorPage> createState() => _UpsertCreatorPageState();
}

class _UpsertCreatorPageState extends ConsumerState<UpsertCreatorPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _otherNameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingCreator != null) {
      final CreatorEntity creator = widget.existingCreator!;
      _nameController.text = creator.name;
      _otherNameController.text = creator.otherName ?? '';
      _websiteController.text = creator.website ?? '';
      _facebookController.text = creator.facebook ?? '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upsertCreatorControllerProvider.notifier).initializeWith(widget.existingCreator);
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final CreatorEntity? savedCreator = await ref
          .read(upsertCreatorControllerProvider.notifier)
          .saveCreator(
            name: _nameController.text.trim(),
            otherName: _otherNameController.text.trim(),
            website: _websiteController.text.trim(),
            facebook: _facebookController.text.trim(),
          );

      final bool isSuccess = savedCreator != null;

      if (isSuccess && mounted) {
        SnackBars.showSuccess(
          widget.existingCreator != null
              ? 'Creator updated successfully'
              : 'Creator added successfully',
        );
        context.pop();
      } else if (!isSuccess && mounted) {
        final UpsertCreatorState state = ref.read(upsertCreatorControllerProvider);
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
    final UpsertCreatorState state = ref.watch(upsertCreatorControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingCreator != null ? 'Edit Creator' : 'Add Creator'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            Center(
              child: GestureDetector(
                onTap: () => ref.read(upsertCreatorControllerProvider.notifier).pickImage(),
                child: Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: Images.getPickerDecoration(
                    theme,
                    image: state.pickedBase64Image != null
                        ? DecorationImage(
                            image: Images.getImageProvider(state.pickedBase64Image),
                            fit: BoxFit.contain,
                          )
                        : null,
                  ),
                  child: state.pickedBase64Image == null
                      ? FaIcon(
                          FontAwesomeIcons.user,
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
                    onPressed: () => ref.read(upsertCreatorControllerProvider.notifier).pickImage(),
                    icon: const FaIcon(FontAwesomeIcons.camera),
                    label: Text(state.pickedBase64Image == null ? 'Add Image' : 'Change Image'),
                  ),
                  if (state.pickedBase64Image != null)
                    TextButton.icon(
                      onPressed: () =>
                          ref.read(upsertCreatorControllerProvider.notifier).clearImage(),
                      icon: const FaIcon(FontAwesomeIcons.trash),
                      label: const Text('Remove Image'),
                      style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            FormSection(
              title: 'Identity',
              icon: FontAwesomeIcons.user,
              children: <Widget>[
                FormTextField(
                  controller: _nameController,
                  label: 'Name',
                  hint: 'Creator Name',
                  prefixIcon: FontAwesomeIcons.user,
                  maxLength: 200,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                FormTextField(
                  controller: _otherNameController,
                  label: 'Other Name',
                  hint: 'Alternative Name',
                  prefixIcon: FontAwesomeIcons.idBadge,
                  maxLength: 200,
                ),
              ],
            ),

            FormSection(
              title: 'Contact',
              icon: FontAwesomeIcons.earthAmericas,
              children: <Widget>[
                FormTextField(
                  controller: _websiteController,
                  label: 'Website',
                  hint: 'https://www.example.com',
                  prefixIcon: FontAwesomeIcons.globe,
                  maxLength: 200,
                  keyboardType: TextInputType.url,
                  validator: Validators.validateWebsiteUrl,
                ),
                const SizedBox(height: 16),
                FormTextField(
                  controller: _facebookController,
                  label: 'Facebook',
                  hint: 'https://www.facebook.com/username',
                  prefixIcon: FontAwesomeIcons.facebook,
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
                  : const FaIcon(FontAwesomeIcons.floppyDisk),
              label: Text(
                state.isLoading
                    ? 'Saving...'
                    : (widget.existingCreator != null ? 'Update Creator' : 'Save Creator'),
              ),
              style: Buttons.getPrimaryFilledButtonStyle(theme),
            ),
          ],
        ),
      ),
    );
  }
}
