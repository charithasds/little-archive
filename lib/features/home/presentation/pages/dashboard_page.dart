import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
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
    final ThemeMode themeMode = ref.watch(themeProvider);
    final ThemeData theme = themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    final ColorScheme colorScheme = theme.colorScheme;

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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
                    gradient: <Color>[colorScheme.primaryContainer, colorScheme.primary],
                    iconColor: colorScheme.onPrimary,
                    count: bookCount,
                    theme: theme,
                    colorScheme: colorScheme,
                    onTap: () => context.go('/books'),
                  ),
                  _DashboardCard(
                    title: _getTitle(workCount, 'Work'),
                    icon: Icons.article_rounded,
                    gradient: <Color>[colorScheme.secondaryContainer, colorScheme.secondary],
                    iconColor: colorScheme.onSecondary,
                    count: workCount,
                    theme: theme,
                    colorScheme: colorScheme,
                    onTap: () => context.go('/works'),
                  ),
                  _DashboardCard(
                    title: _getTitle(authorCount, 'Author'),
                    icon: Icons.person_rounded,
                    gradient: <Color>[colorScheme.tertiaryContainer, colorScheme.tertiary],
                    iconColor: colorScheme.onTertiary,
                    count: authorCount,
                    theme: theme,
                    colorScheme: colorScheme,
                    onTap: () => context.go('/authors'),
                  ),
                  _DashboardCard(
                    title: _getTitle(translatorCount, 'Translator'),
                    icon: Icons.translate_rounded,
                    gradient: <Color>[colorScheme.primaryContainer, colorScheme.primary],
                    iconColor: colorScheme.onPrimary,
                    count: translatorCount,
                    theme: theme,
                    colorScheme: colorScheme,
                    onTap: () => context.go('/translators'),
                  ),
                  _DashboardCard(
                    title: _getTitle(publisherCount, 'Publisher'),
                    icon: Icons.business_rounded,
                    gradient: <Color>[colorScheme.secondaryContainer, colorScheme.secondary],
                    iconColor: colorScheme.onSecondary,
                    count: publisherCount,
                    theme: theme,
                    colorScheme: colorScheme,
                    onTap: () => context.go('/publishers'),
                  ),
                  _DashboardCard(
                    title: _getTitle(sequenceCount, 'Sequence'),
                    icon: Icons.layers_rounded,
                    gradient: <Color>[colorScheme.tertiaryContainer, colorScheme.tertiary],
                    iconColor: colorScheme.onTertiary,
                    count: sequenceCount,
                    theme: theme,
                    colorScheme: colorScheme,
                    onTap: () => context.go('/sequences'),
                  ),
                  _DashboardCard(
                    title: _getTitle(readerCount, 'Reader'),
                    icon: Icons.face_rounded,
                    gradient: <Color>[colorScheme.primaryContainer, colorScheme.primary],
                    iconColor: colorScheme.onPrimary,
                    count: readerCount,
                    theme: theme,
                    colorScheme: colorScheme,
                    onTap: () => context.go('/readers'),
                  ),
                ]),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        );
      },
    );
  }

  static int? _getCount(AsyncValue<List<dynamic>> asyncValue) => asyncValue.when(
    data: (List<dynamic> d) => d.length,
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

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.iconColor,
    required this.count,
    required this.theme,
    required this.colorScheme,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final List<Color> gradient;
  final Color iconColor;
  final int? count;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    clipBehavior: Clip.hardEdge,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[gradient[0].withValues(alpha: 0.3), gradient[1].withValues(alpha: 0.1)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: gradient[1].withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const Spacer(),
            if (count != null)
              Text(
                count.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            else
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: gradient[1]),
              ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
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
