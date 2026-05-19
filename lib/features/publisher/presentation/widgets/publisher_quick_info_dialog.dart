import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/widgets/detail_tile.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_circle_image.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_loading.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_metadata.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/publisher_entity.dart';
import '../providers/publisher_provider.dart';

class PublisherQuickInfoDialog extends ConsumerWidget {
  const PublisherQuickInfoDialog({super.key, required this.publisherId});

  final String publisherId;

  static void show(BuildContext context, String publisherId) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => PublisherQuickInfoDialog(publisherId: publisherId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final AsyncValue<PublisherEntity?> async = ref.watch(publisherProvider(publisherId));

    final Widget content = async.when(
      data: (PublisherEntity? publisher) {
        if (publisher == null) {
          return const Text('Publisher not found');
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InfoDialogCircleImage(image: publisher.logo, icon: Icons.business_rounded),
            const SizedBox(height: 16),
            Text(publisher.name, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (publisher.otherName != null && publisher.otherName!.isNotEmpty)
              Text(
                publisher.otherName!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const Divider(height: 32),
            DetailTile(
              label: 'Books Count',
              value: '${publisher.bookIds.length} books',
              leadingIcon: Icons.book_rounded,
            ),
            InfoDialogMetadata(created: publisher.createdDate, updated: publisher.lastUpdated),
          ],
        );
      },
      loading: () => const InfoDialogLoading(),
      error: (Object e, _) => Text('Error: $e'),
    );

    return AlertDialog(
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Publisher Info'),
      content: SingleChildScrollView(child: SizedBox(width: 450, child: content)),
      actions: <Widget>[TextButton(onPressed: () => context.pop(), child: const Text('Close'))],
    );
  }
}
