import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/widgets/detail_tile.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_circle_image.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_loading.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_metadata.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/reader_entity.dart';
import '../providers/reader_provider.dart';

class ReaderQuickInfoDialog extends ConsumerWidget {
  const ReaderQuickInfoDialog({super.key, required this.readerId});

  final String readerId;

  static void show(BuildContext context, String readerId) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => ReaderQuickInfoDialog(readerId: readerId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final AsyncValue<ReaderEntity?> async = ref.watch(readerProvider(readerId));

    final Widget content = async.when(
      data: (ReaderEntity? reader) {
        if (reader == null) {
          return const Text('Reader not found');
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InfoDialogCircleImage(image: reader.image, icon: FontAwesomeIcons.smile),
            const SizedBox(height: 16),
            Text(reader.name, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (reader.otherName != null && reader.otherName!.isNotEmpty)
              Text(
                reader.otherName!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const Divider(height: 32),
            DetailTile(
              label: 'Books Count',
              value: '${reader.bookIds.length} books',
              leadingIcon: FontAwesomeIcons.book,
            ),
            InfoDialogMetadata(created: reader.createdDate, updated: reader.lastUpdated),
          ],
        );
      },
      loading: () => const InfoDialogLoading(),
      error: (Object e, _) => Text('Error: $e'),
    );

    return AlertDialog(
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Reader Info'),
      content: SingleChildScrollView(child: SizedBox(width: 450, child: content)),
      actions: <Widget>[TextButton(onPressed: () => context.pop(), child: const Text('Close'))],
    );
  }
}
