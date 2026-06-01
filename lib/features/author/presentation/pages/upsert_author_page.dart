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
import '../../domain/entities/author_entity.dart';
import '../providers/upsert_author_controller.dart';

class UpsertAuthorPage extends ConsumerStatefulWidget {
  const UpsertAuthorPage({super.key, this.existingAuthor});

  final AuthorEntity? existingAuthor;

  @override
  ConsumerState<UpsertAuthorPage> createState() => _UpsertAuthorPageState();
}

class _UpsertAuthorPageState extends ConsumerState<UpsertAuthorPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _otherNameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingAuthor != null) {
      final AuthorEntity author = widget.existingAuthor!;
      _nameController.text = author.name;
      _otherNameController.text = author.otherName ?? '';
      _websiteController.text = author.website ?? '';
      _facebookController.text = author.facebook ?? '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upsertAuthorControllerProvider.notifier).initializeWith(widget.existingAuthor);
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final AuthorEntity? savedAuthor = await ref
          .read(upsertAuthorControllerProvider.notifier)
          .saveAuthor(
            name: _nameController.text.trim(),
            otherName: _otherNameController.text.trim(),
            website: _websiteController.text.trim(),
            facebook: _facebookController.text.trim(),
          );

      final bool isSuccess = savedAuthor != null;

      if (isSuccess && mounted) {
        SnackBars.showSuccess(
          widget.existingAuthor != null
              ? 'Author updated successfully'
              : 'Author added successfully',
        );
        context.pop();
      } else if (!isSuccess && mounted) {
        final UpsertAuthorState state = ref.read(upsertAuthorControllerProvider);
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
    final UpsertAuthorState state = ref.watch(upsertAuthorControllerProvider);

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
                onTap: () => ref.read(upsertAuthorControllerProvider.notifier).pickImage(),
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
                    onPressed: () => ref.read(upsertAuthorControllerProvider.notifier).pickImage(),
                    icon: const FaIcon(FontAwesomeIcons.camera),
                    label: Text(state.pickedBase64Image == null ? 'Add Image' : 'Change Image'),
                  ),
                  if (state.pickedBase64Image != null)
                    TextButton.icon(
                      onPressed: () =>
                          ref.read(upsertAuthorControllerProvider.notifier).clearImage(),
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
                  hint: 'Author Name',
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
                    : (widget.existingAuthor != null ? 'Update Author' : 'Save Author'),
              ),
              style: Buttons.getPrimaryFilledButtonStyle(theme),
            ),
          ],
        ),
      ),
    );
  }
}
