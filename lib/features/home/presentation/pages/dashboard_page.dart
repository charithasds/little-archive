import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../author/domain/entities/author_entity.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../../reader/domain/entities/reader_entity.dart';
import '../../../reader/presentation/providers/reader_provider.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../translator/domain/entities/translator_entity.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../../work/domain/entities/work_entity.dart';
import '../../../work/presentation/providers/work_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<BookEntity>> booksAsync = ref.watch(booksStreamProvider);
    final AsyncValue<List<WorkEntity>> worksAsync = ref.watch(worksStreamProvider);
    final AsyncValue<List<AuthorEntity>> authorsAsync = ref.watch(authorsStreamProvider);
    final AsyncValue<List<TranslatorEntity>> translatorsAsync = ref.watch(
      translatorsStreamProvider,
    );
    final AsyncValue<List<PublisherEntity>> publishersAsync = ref.watch(publishersStreamProvider);
    final AsyncValue<List<SequenceEntity>> sequencesAsync = ref.watch(sequencesStreamProvider);
    final AsyncValue<List<ReaderEntity>> readersAsync = ref.watch(readersStreamProvider);

    final int? bookCount = _getCount(booksAsync);
    final int? workCount = _getCount(worksAsync);
    final int? authorCount = _getCount(authorsAsync);
    final int? translatorCount = _getCount(translatorsAsync);
    final int? publisherCount = _getCount(publishersAsync);
    final int? sequenceCount = _getCount(sequencesAsync);
    final int? readerCount = _getCount(readersAsync);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isLargeScreen = constraints.maxWidth >= 600;
        const double aspectRatio = 0.95;

        return CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isLargeScreen ? 220 : 200,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: aspectRatio,
                ),
                delegate: SliverChildListDelegate(<Widget>[
                  _DashboardCard(
                    title: _getTitle(bookCount, 'Book'),
                    icon: Icons.book_rounded,
                    count: bookCount,
                    onTap: () => context.go('/books'),
                  ),
                  _DashboardCard(
                    title: _getTitle(workCount, 'Work'),
                    icon: Icons.article_rounded,
                    count: workCount,
                    onTap: () => context.go('/works'),
                  ),
                  _DashboardCard(
                    title: _getTitle(authorCount, 'Author'),
                    icon: Icons.person_rounded,
                    count: authorCount,
                    onTap: () => context.go('/authors'),
                  ),
                  _DashboardCard(
                    title: _getTitle(translatorCount, 'Translator'),
                    icon: Icons.translate_rounded,
                    count: translatorCount,
                    onTap: () => context.go('/translators'),
                  ),
                  _DashboardCard(
                    title: _getTitle(publisherCount, 'Publisher'),
                    icon: Icons.business_rounded,
                    count: publisherCount,
                    onTap: () => context.go('/publishers'),
                  ),
                  _DashboardCard(
                    title: _getTitle(sequenceCount, 'Sequence'),
                    icon: Icons.layers_rounded,
                    count: sequenceCount,
                    onTap: () => context.go('/sequences'),
                  ),
                  _DashboardCard(
                    title: _getTitle(readerCount, 'Reader'),
                    icon: Icons.face_rounded,
                    count: readerCount,
                    onTap: () => context.go('/readers'),
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  static int? _getCount(AsyncValue<List<Object?>> asyncValue) => asyncValue.when(
    data: (List<Object?> d) => d.length,
    loading: () => null,
    error: (Object err, StackTrace stack) => 0,
  );

  static String _getTitle(int? count, String singular) {
    if (count == null) {
      return singular;
    }
    return count == 1 ? singular : '${singular}s';
  }
}

class _DashboardCard extends ConsumerWidget {
  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.count,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color iconColor = isDark ? Colors.white : colorScheme.onPrimary;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const Spacer(),
              if (count != null)
                Text(
                  count.toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                )
              else
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
