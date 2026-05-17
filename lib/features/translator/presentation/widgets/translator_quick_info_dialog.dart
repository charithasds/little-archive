import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/widgets/detail_tile.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_circle_image.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_loading.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_metadata.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/translator_entity.dart';
import '../providers/translator_provider.dart';

class TranslatorQuickInfoDialog extends ConsumerWidget {
  const TranslatorQuickInfoDialog({super.key, required this.translatorId});

  final String translatorId;

  static void show(BuildContext context, String translatorId) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => TranslatorQuickInfoDialog(translatorId: translatorId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final AsyncValue<TranslatorEntity?> async = ref.watch(translatorProvider(translatorId));

    final Widget content = async.when(
      data: (TranslatorEntity? translator) {
        if (translator == null) {
          return const Text('Translator not found');
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InfoDialogCircleImage(image: translator.image, icon: Icons.translate_rounded),
            const SizedBox(height: 16),
            Text(translator.name, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (translator.otherName != null && translator.otherName!.isNotEmpty)
              Text(
                translator.otherName!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const Divider(height: 32),
            DetailTile(
              label: 'Books Count',
              value: '${translator.bookIds.length} books',
              leadingIcon: Icons.book_rounded,
            ),
            DetailTile(
              label: 'Works Count',
              value: '${translator.workIds.length} works',
              leadingIcon: Icons.article_rounded,
            ),
            InfoDialogMetadata(created: translator.createdDate, updated: translator.lastUpdated),
          ],
        );
      },
      loading: () => const InfoDialogLoading(),
      error: (Object e, _) => Text('Error: $e'),
    );

    return AlertDialog(
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Translator Info'),
      content: SingleChildScrollView(child: SizedBox(width: 450, child: content)),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    );
  }
}
