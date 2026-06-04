import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/presentation/widgets/info_dialog_loading.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_metadata.dart';
import '../../../../core/shared/presentation/widgets/info_dialog_rectangle_image.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../author/domain/entities/author_entity.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../translator/domain/entities/translator_entity.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
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
    final List<AuthorEntity>? authors = ref.watch(authorsStreamProvider).value;
    final List<TranslatorEntity>? translators = ref.watch(translatorsStreamProvider).value;

    final Widget content = async.when(
      data: (WorkEntity? work) {
        if (work == null) {
          return const Text('Work not found');
        }

        final AsyncValue<BookEntity?>? bookAsync = (work.bookId != null && work.bookId!.isNotEmpty)
            ? ref.watch(bookProvider(work.bookId!))
            : null;

        final List<String> authorNames = <String>[];
        if (authors != null) {
          for (final String id in work.authorIds) {
            final AuthorEntity? a = authors.where((AuthorEntity x) => x.id == id).firstOrNull;
            if (a != null) {
              authorNames.add(a.name);
            }
          }
        }

        final List<String> translatorNames = <String>[];
        if (translators != null) {
          for (final String id in work.translatorIds) {
            final TranslatorEntity? t = translators.where((TranslatorEntity x) => x.id == id).firstOrNull;
            if (t != null) {
              translatorNames.add(t.name);
            }
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InfoDialogImageRectangle(
              icon: FontAwesomeIcons.fileLines,
              image: bookAsync?.when(
                data: (BookEntity? book) => book?.cover,
                loading: () => null,
                error: (Object e, _) => null,
              ),
            ),
            const SizedBox(height: 16),
            Text(work.title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (work.originalTitle != null && work.originalTitle!.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                work.originalTitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const Divider(height: 24),
            if (authorNames.isNotEmpty) ...<Widget>[
              _buildField('Author', authorNames.join(', '), theme),
              const SizedBox(height: 4),
            ],
            if (work.isTranslation && translatorNames.isNotEmpty) ...<Widget>[
              _buildField('Translator', translatorNames.join(', '), theme),
              const SizedBox(height: 4),
            ],
            if (authorNames.isNotEmpty || (work.isTranslation && translatorNames.isNotEmpty))
              const Divider(height: 24),
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

  Widget _buildField(String label, String value, ThemeData theme) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 90,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
}
