import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/widgets/detail_tile.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_circle_image.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_loading.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_metadata.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/creator_entity.dart';
import '../providers/creator_provider.dart';

class CreatorQuickInfoDialog extends ConsumerWidget {
  const CreatorQuickInfoDialog({super.key, required this.creatorId});

  final String creatorId;

  static void show(BuildContext context, String creatorId) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => CreatorQuickInfoDialog(creatorId: creatorId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final AsyncValue<CreatorEntity?> async = ref.watch(creatorProvider(creatorId));

    final Widget content = async.when(
      data: (CreatorEntity? creator) {
        if (creator == null) {
          return const Text('Creator not found');
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InfoDialogCircleImage(image: creator.image, icon: FontAwesomeIcons.user),
            const SizedBox(height: 16),
            Text(creator.name, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (creator.otherName != null && creator.otherName!.isNotEmpty)
              Text(
                creator.otherName!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const Divider(height: 32),
            DetailTile(
              label: 'Books Count',
              value: '${creator.authoredBookIds.length + creator.translatedBookIds.length} books',
              leadingIcon: FontAwesomeIcons.book,
            ),
            DetailTile(
              label: 'Works Count',
              value: '${creator.authoredWorkIds.length + creator.translatedWorkIds.length} works',
              leadingIcon: FontAwesomeIcons.fileLines,
            ),
            InfoDialogMetadata(created: creator.createdDate, updated: creator.lastUpdated),
          ],
        );
      },
      loading: () => const InfoDialogLoading(),
      error: (Object e, _) => Text('Error: $e'),
    );

    return AlertDialog(
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Creator Info'),
      content: SingleChildScrollView(child: SizedBox(width: 450, child: content)),
      actions: <Widget>[TextButton(onPressed: () => context.pop(), child: const Text('Close'))],
    );
  }
}
