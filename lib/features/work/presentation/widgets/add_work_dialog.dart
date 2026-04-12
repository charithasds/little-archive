import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/domain/enums/content_category.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/presentation/utils/button_styles.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/single_select_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../domain/entities/work_entity.dart';
import '../providers/upsert_work_controller.dart';

class AddWorkDialog extends ConsumerStatefulWidget {
  const AddWorkDialog({super.key});

  @override
  ConsumerState<AddWorkDialog> createState() => _AddWorkDialogState();
}

class _AddWorkDialogState extends ConsumerState<AddWorkDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  ContentCategory _contentCategory = ContentCategory.shortStory;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final WorkEntity? savedWork = await ref
          .read(upsertWorkControllerProvider.notifier)
          .saveWork(
            existingWork: null,
            title: _titleController.text.trim(),
            language: null,
            genre: null,
            contentCategory: _contentCategory,
            noOfPages: null,
            isTranslation: false,
            originalTitle: null,
            originalLanguage: null,
            readingStatus: ReadingStatus.notStarted,
            pausedPage: null,
            completedDate: null,
            notes: null,
            authorIds: <String>[],
            translatorIds: <String>[],
            selectedSequences: <SequenceEntity, String>{},
            bookId: null,
          );

      if (mounted) {
        if (savedWork != null) {
          SnackBars.showSuccess(context, 'Work added successfully');
          Navigator.of(context).pop(savedWork);
        } else {
          final UpsertWorkState state = ref.read(upsertWorkControllerProvider);

          if (state.error != null) {
            SnackBars.showError(context, state.error!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final UpsertWorkState state = ref.watch(upsertWorkControllerProvider);

    return AlertDialog(
      title: const Text('Add Work'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FormTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'Work Title',
              isRequired: true,
              maxLength: 200,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            SingleSelectField<ContentCategory>(
              label: 'Content Category',
              items: ContentCategory.values,
              value: _contentCategory,
              itemLabel: (ContentCategory c) => c.name.toUpperCase(),
              onChanged: (ContentCategory? category) {
                if (category != null) {
                  setState(() => _contentCategory = category);
                }
              },
              isNullable: false,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: state.isLoading ? null : _save,
          style: ButtonStyles.getPrimaryFilledButtonStyle(
            theme,
          ).copyWith(minimumSize: WidgetStateProperty.all(const Size(100, 44))),
          child: state.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
