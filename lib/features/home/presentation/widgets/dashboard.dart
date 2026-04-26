import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../author/presentation/providers/author_provider.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../../reader/presentation/providers/reader_provider.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../../work/presentation/providers/work_provider.dart';
import 'dashboard_card.dart';

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> bookCountAsync = ref.watch(bookCountProvider);
    final AsyncValue<int> workCountAsync = ref.watch(workCountProvider);
    final AsyncValue<int> authorCountAsync = ref.watch(authorCountProvider);
    final AsyncValue<int> translatorCountAsync = ref.watch(translatorCountProvider);
    final AsyncValue<int> publisherCountAsync = ref.watch(publisherCountProvider);
    final AsyncValue<int> sequenceCountAsync = ref.watch(sequenceCountProvider);
    final AsyncValue<int> readerCountAsync = ref.watch(readerCountProvider);

    final int? bookCount = bookCountAsync.value;
    final int? workCount = workCountAsync.value;
    final int? authorCount = authorCountAsync.value;
    final int? translatorCount = translatorCountAsync.value;
    final int? publisherCount = publisherCountAsync.value;
    final int? sequenceCount = sequenceCountAsync.value;
    final int? readerCount = readerCountAsync.value;

    final List<_CardDef> cards = <_CardDef>[
      _CardDef(
        title: _label(bookCount, 'Book'),
        icon: Icons.book_rounded,
        count: bookCount,
        route: '/books',
      ),
      _CardDef(
        title: _label(workCount, 'Work'),
        icon: Icons.article_rounded,
        count: workCount,
        route: '/works',
      ),
      _CardDef(
        title: _label(authorCount, 'Author'),
        icon: Icons.person_rounded,
        count: authorCount,
        route: '/authors',
      ),
      _CardDef(
        title: _label(translatorCount, 'Translator'),
        icon: Icons.translate_rounded,
        count: translatorCount,
        route: '/translators',
      ),
      _CardDef(
        title: _label(publisherCount, 'Publisher'),
        icon: Icons.business_rounded,
        count: publisherCount,
        route: '/publishers',
      ),
      _CardDef(
        title: _label(sequenceCount, 'Sequence'),
        icon: Icons.layers_rounded,
        count: sequenceCount,
        route: '/sequences',
      ),
      _CardDef(
        title: _label(readerCount, 'Reader'),
        icon: Icons.face_rounded,
        count: readerCount,
        route: '/readers',
      ),
    ];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.95,
            ),
            delegate: SliverChildListDelegate(<Widget>[
              for (final _CardDef c in cards)
                DashboardCard(
                  title: c.title,
                  icon: c.icon,
                  count: c.count,
                  onTap: () => context.go(c.route),
                ),
            ]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  static String _label(int? count, String singular) {
    if (count == null) {
      return singular;
    }
    return count == 1 ? singular : '${singular}s';
  }
}

class _CardDef {
  const _CardDef({
    required this.title,
    required this.icon,
    required this.count,
    required this.route,
  });

  final String title;
  final IconData icon;
  final int? count;
  final String route;
}
