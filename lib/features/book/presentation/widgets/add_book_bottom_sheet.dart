import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_bottom_sheet.dart';
import '../../../../core/shared/presentation/widgets/form_dropdown_field.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/loading_filled_button.dart';
import '../../domain/entities/book_entity.dart';
import '../providers/upsert_book_controller.dart';

class AddBookBottomSheet extends ConsumerStatefulWidget {
  const AddBookBottomSheet({
    super.key,
    this.allowedTypes,
  });

  /// Restricts which compilation types are shown in the dropdown.
  /// If null, all types are shown.
  final List<CompilationType>? allowedTypes;

  @override
  ConsumerState<AddBookBottomSheet> createState() => _AddBookBottomSheetState();
}

class _AddBookBottomSheetState extends ConsumerState<AddBookBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  late CompilationType _compilationType;

  @override
  void initState() {
    super.initState();
    final List<CompilationType> allowed = widget.allowedTypes ?? CompilationType.values;
    _compilationType = allowed.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upsertBookControllerProvider.notifier).initializeWith(null);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final BookEntity? savedBook = await ref.read(upsertBookControllerProvider.notifier).saveBook(
            title: _titleController.text.trim(),
            compilationType: _compilationType,
            isTranslation: false,
          );

      if (mounted) {
        if (savedBook != null) {
          SnackBars.showSuccess('Book added successfully');
          context.pop(savedBook);
        } else {
          final UpsertBookState state = ref.read(upsertBookControllerProvider);

          if (state.error != null) {
            SnackBars.showError(state.error!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UpsertBookState state = ref.watch(upsertBookControllerProvider);

    return FormBottomSheet(
      title: 'Add Book',
      actions: <Widget>[
        LoadingFilledButton(
          onPressed: _save,
          isLoading: state.isLoading,
          label: 'Save Book',
          icon: Icons.save_rounded,
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FormTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'Book Title',
              prefixIcon: Icons.book_rounded,
              isRequired: true,
              maxLength: 200,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            FormDropdownField<CompilationType>(
              label: 'Compilation Type',
              prefixIcon: Icons.collections_bookmark_rounded,
              items: widget.allowedTypes ?? CompilationType.values,
              value: _compilationType,
              itemLabel: (CompilationType c) => c.clientValue,
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
    );
  }
}
