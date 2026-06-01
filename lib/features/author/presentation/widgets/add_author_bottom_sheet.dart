import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_bottom_sheet.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/loading_filled_button.dart';
import '../../domain/entities/author_entity.dart';
import '../providers/upsert_author_controller.dart';

class AddAuthorBottomSheet extends ConsumerStatefulWidget {
  const AddAuthorBottomSheet({super.key});

  @override
  ConsumerState<AddAuthorBottomSheet> createState() => _AddAuthorBottomSheetState();
}

class _AddAuthorBottomSheetState extends ConsumerState<AddAuthorBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upsertAuthorControllerProvider.notifier).initializeWith(null);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final AuthorEntity? savedAuthor = await ref
          .read(upsertAuthorControllerProvider.notifier)
          .saveAuthor(name: _nameController.text.trim());

      if (mounted) {
        if (savedAuthor != null) {
          SnackBars.showSuccess('Author added successfully');
          context.pop(savedAuthor);
        } else {
          final UpsertAuthorState state = ref.read(upsertAuthorControllerProvider);

          if (state.error != null) {
            SnackBars.showError(state.error!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UpsertAuthorState state = ref.watch(upsertAuthorControllerProvider);

    return FormBottomSheet(
      title: 'Add Author',
      actions: <Widget>[
        LoadingFilledButton(
          onPressed: _save,
          isLoading: state.isLoading,
          label: 'Save Author',
          icon: FontAwesomeIcons.floppyDisk,
        ),
      ],
      child: Form(
        key: _formKey,
        child: FormTextField(
          controller: _nameController,
          label: 'Name',
          hint: 'Author Name',
          prefixIcon: FontAwesomeIcons.user,
          isRequired: true,
          maxLength: 200,
          autofocus: true,
        ),
      ),
    );
  }
}
