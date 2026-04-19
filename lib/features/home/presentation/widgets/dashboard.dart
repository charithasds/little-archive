import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import 'dashboard_card.dart';

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});

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
                  DashboardCard(
                    title: _getTitle(bookCount, 'Book'),
                    icon: Icons.book_rounded,
                    count: bookCount,
                    onTap: () => context.go('/books'),
                  ),
                  DashboardCard(
                    title: _getTitle(workCount, 'Work'),
                    icon: Icons.article_rounded,
                    count: workCount,
                    onTap: () => context.go('/works'),
                  ),
                  DashboardCard(
                    title: _getTitle(authorCount, 'Author'),
                    icon: Icons.person_rounded,
                    count: authorCount,
                    onTap: () => context.go('/authors'),
                  ),
                  DashboardCard(
                    title: _getTitle(translatorCount, 'Translator'),
                    icon: Icons.translate_rounded,
                    count: translatorCount,
                    onTap: () => context.go('/translators'),
                  ),
                  DashboardCard(
                    title: _getTitle(publisherCount, 'Publisher'),
                    icon: Icons.business_rounded,
                    count: publisherCount,
                    onTap: () => context.go('/publishers'),
                  ),
                  DashboardCard(
                    title: _getTitle(sequenceCount, 'Sequence'),
                    icon: Icons.layers_rounded,
                    count: sequenceCount,
                    onTap: () => context.go('/sequences'),
                  ),
                  DashboardCard(
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
