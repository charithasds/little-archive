import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/presentation/utils/button_styles.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/single_select_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../domain/entities/book_entity.dart';
import '../providers/upsert_book_controller.dart';

class AddBookDialog extends ConsumerStatefulWidget {
  const AddBookDialog({super.key});

  @override
  ConsumerState<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends ConsumerState<AddBookDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  CompilationType _compilationType = CompilationType.collection;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final BookEntity? savedBook = await ref
          .read(upsertBookControllerProvider.notifier)
          .saveBook(
            existingBook: null,
            title: _titleController.text.trim(),
            compilationType: _compilationType,
            language: null,
            genre: null,
            isbn: null,
            publishedDate: null,
            noOfPages: null,
            isTranslation: false,
            originalTitle: null,
            originalLanguage: null,
            collectionStatus: CollectionStatus.collected,
            collectedDate: null,
            lendedDate: null,
            dueDate: null,
            readingStatus: ReadingStatus.notStarted,
            pausedPage: null,
            completedDate: null,
            notes: null,
            authorIds: <String>[],
            translatorIds: <String>[],
            workIds: <String>[],
            selectedSequences: <SequenceEntity, String>{},
            publisherId: null,
            readerId: null,
          );

      if (mounted) {
        if (savedBook != null) {
          SnackBars.showSuccess(context, 'Book added successfully');
          Navigator.of(context).pop(savedBook);
        } else {
          final UpsertBookState state = ref.read(upsertBookControllerProvider);

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
    final UpsertBookState state = ref.watch(upsertBookControllerProvider);

    return AlertDialog(
      title: const Text('Add Book'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FormTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'Book Title',
              isRequired: true,
              maxLength: 200,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            SingleSelectField<CompilationType>(
              label: 'Compilation Type',
              items: CompilationType.values,
              value: _compilationType,
              itemLabel: (CompilationType c) => c.name.toUpperCase(),
              onChanged: (CompilationType? type) {
                if (type != null) {
                  setState(() => _compilationType = type);
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
