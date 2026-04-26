import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/enums/content_category.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_bottom_sheet.dart';
import '../../../../core/shared/presentation/widgets/form_dropdown_field.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/loading_filled_button.dart';
import '../../domain/entities/work_entity.dart';
import '../providers/upsert_work_controller.dart';

class AddWorkBottomSheet extends ConsumerStatefulWidget {
  const AddWorkBottomSheet({super.key});

  @override
  ConsumerState<AddWorkBottomSheet> createState() => _AddWorkBottomSheetState();
}

class _AddWorkBottomSheetState extends ConsumerState<AddWorkBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  ContentCategory _contentCategory = ContentCategory.shortStory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upsertWorkControllerProvider.notifier).initializeWith(null);
    });
  }

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
            title: _titleController.text.trim(),
            contentCategory: _contentCategory,
            isTranslation: false,
          );

      if (mounted) {
        if (savedWork != null) {
          SnackBars.showSuccess('Work added successfully');
          context.pop(savedWork);
        } else {
          final UpsertWorkState state = ref.read(upsertWorkControllerProvider);

          if (state.error != null) {
            SnackBars.showError(state.error!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UpsertWorkState state = ref.watch(upsertWorkControllerProvider);

    return FormBottomSheet(
      title: 'Add Work',
      actions: <Widget>[
        LoadingFilledButton(
          onPressed: _save,
          isLoading: state.isLoading,
          label: 'Save Work',
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
              hint: 'Work Title',
              prefixIcon: Icons.article_rounded,
              isRequired: true,
              maxLength: 200,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            FormDropdownField<ContentCategory>(
              label: 'Content Category',
              prefixIcon: Icons.topic_rounded,
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
    );
  }
}
