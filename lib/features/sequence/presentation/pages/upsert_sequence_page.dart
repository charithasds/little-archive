import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_section.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/sequence_entity.dart';
import '../providers/upsert_sequence_controller.dart';

class UpsertSequencePage extends ConsumerStatefulWidget {
  const UpsertSequencePage({super.key, this.existingSequence});

  final SequenceEntity? existingSequence;

  @override
  ConsumerState<UpsertSequencePage> createState() => _UpsertSequencePageState();
}

class _UpsertSequencePageState extends ConsumerState<UpsertSequencePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _otherNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingSequence != null) {
      final SequenceEntity sequence = widget.existingSequence!;
      _nameController.text = sequence.name;
      _otherNameController.text = sequence.otherName ?? '';
      _notesController.text = sequence.notes ?? '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upsertSequenceControllerProvider.notifier).initializeWith(widget.existingSequence);
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final SequenceEntity? result = await ref
          .read(upsertSequenceControllerProvider.notifier)
          .saveSequence(
            name: _nameController.text.trim(),
            otherName: _otherNameController.text.trim(),
            notes: _notesController.text.trim(),
          );

      if (result != null && mounted) {
        SnackBars.showSuccess(
          widget.existingSequence != null
              ? 'Sequence updated successfully'
              : 'Sequence added successfully',
        );
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _otherNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final UpsertSequenceState state = ref.watch(upsertSequenceControllerProvider);

    ref.listen<UpsertSequenceState>(upsertSequenceControllerProvider, (
      UpsertSequenceState? previous,
      UpsertSequenceState next,
    ) {
      if (next.error != null && next.error != previous?.error) {
        SnackBars.showError(next.error!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingSequence != null ? 'Edit Sequence' : 'Add Sequence'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: Images.getPickerDecoration(theme, shape: ImageShape.square),
                child: Icon(
                  Icons.layers_rounded,
                  size: 48,
                  color: Images.getPickerIconColor(theme),
                ),
              ),
            ),
            FormSection(
              title: 'Identity',
              icon: Icons.person_outline_rounded,
              children: <Widget>[
                FormTextField(
                  controller: _nameController,
                  label: 'Name',
                  hint: 'Sequence Name',
                  prefixIcon: Icons.layers_rounded,
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
              title: 'Additional Information',
              icon: Icons.notes_rounded,
              children: <Widget>[
                FormTextField(
                  controller: _notesController,
                  label: 'Notes',
                  hint: 'Notes about this Sequence',
                  prefixIcon: Icons.notes_rounded,
                  maxLength: 500,
                  maxLines: 3,
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
                    : (widget.existingSequence != null ? 'Update Sequence' : 'Save Sequence'),
              ),
              style: Buttons.getPrimaryFilledButtonStyle(theme),
            ),
          ],
        ),
      ),
    );
  }
}
