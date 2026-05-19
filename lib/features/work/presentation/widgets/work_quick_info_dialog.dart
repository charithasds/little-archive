import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/widgets/info_dialog_loading.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_metadata.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_rectangle_image.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../domain/entities/work_entity.dart';
import '../providers/work_provider.dart';

class WorkQuickInfoDialog extends ConsumerWidget {
  const WorkQuickInfoDialog({super.key, required this.workId});

  final String workId;

  static void show(BuildContext context, String workId) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => WorkQuickInfoDialog(workId: workId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final AsyncValue<WorkEntity?> async = ref.watch(workProvider(workId));

    final Widget content = async.when(
      data: (WorkEntity? work) {
        if (work == null) {
          return const Text('Work not found');
        }

        final AsyncValue<BookEntity?>? bookAsync = (work.bookId != null && work.bookId!.isNotEmpty)
            ? ref.watch(bookProvider(work.bookId!))
            : null;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InfoDialogImageRectangle(
              icon: Icons.article_rounded,
              image: bookAsync?.when(
                data: (BookEntity? book) => book?.cover,
                loading: () => null,
                error: (Object e, _) => null,
              ),
            ),
            const SizedBox(height: 16),
            Text(work.title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (work.originalTitle != null && work.originalTitle!.isNotEmpty)
              Text(
                work.originalTitle!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const Divider(height: 32),
            InfoDialogMetadata(created: work.createdDate, updated: work.lastUpdated),
          ],
        );
      },
      loading: () => const InfoDialogLoading(),
      error: (Object e, _) => Text('Error: $e'),
    );

    return AlertDialog(
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Work Info'),
      content: SingleChildScrollView(child: SizedBox(width: 450, child: content)),
      actions: <Widget>[TextButton(onPressed: () => context.pop(), child: const Text('Close'))],
    );
  }
}
