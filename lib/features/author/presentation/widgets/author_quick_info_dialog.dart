import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/widgets/detail_tile.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_circle_image.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_loading.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_metadata.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../domain/entities/author_entity.dart';
import '../providers/author_provider.dart';

class AuthorQuickInfoDialog extends ConsumerWidget {
  const AuthorQuickInfoDialog({super.key, required this.authorId});

  final String authorId;

  static void show(BuildContext context, String authorId) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AuthorQuickInfoDialog(authorId: authorId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final AsyncValue<AuthorEntity?> async = ref.watch(authorProvider(authorId));

    final Widget content = async.when(
      data: (AuthorEntity? author) {
        if (author == null) {
          return const Text('Author not found');
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InfoDialogCircleImage(image: author.image, icon: FontAwesomeIcons.user),
            const SizedBox(height: 16),
            Text(author.name, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (author.otherName != null && author.otherName!.isNotEmpty)
              Text(
                author.otherName!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const Divider(height: 32),
            DetailTile(
              label: 'Books Count',
              value: '${author.bookIds.length} books',
              leadingIcon: FontAwesomeIcons.book,
            ),
            DetailTile(
              label: 'Works Count',
              value: '${author.workIds.length} works',
              leadingIcon: FontAwesomeIcons.fileLines,
            ),
            InfoDialogMetadata(created: author.createdDate, updated: author.lastUpdated),
          ],
        );
      },
      loading: () => const InfoDialogLoading(),
      error: (Object e, _) => Text('Error: $e'),
    );

    return AlertDialog(
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Author Info'),
      content: SingleChildScrollView(child: SizedBox(width: 450, child: content)),
      actions: <Widget>[TextButton(onPressed: () => context.pop(), child: const Text('Close'))],
    );
  }
}
