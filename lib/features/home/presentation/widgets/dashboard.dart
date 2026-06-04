import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../book_fair/domain/entities/book_fair_event_entity.dart';
import '../../../book_fair/presentation/providers/book_fair_event_provider.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../../reader/presentation/providers/reader_provider.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../../work/presentation/providers/work_provider.dart';
import 'dashboard_card.dart';

// ── Breakpoints ────────────────────────────────────────────────────────────

const double _kCompact = 600;
const double _kExpanded = 900;

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme cs = theme.colorScheme;
    final double width = MediaQuery.sizeOf(context).width;
    final bool isCompact = width < _kCompact;
    final bool isExpanded = width >= _kExpanded;

    // ── Entity counts ──────────────────────────────────────────────────
    final AsyncValue<int> bookCountAsync = ref.watch(bookCountProvider);
    final AsyncValue<int> workCountAsync = ref.watch(workCountProvider);
    final AsyncValue<int> authorCountAsync = ref.watch(authorCountProvider);
    final AsyncValue<int> translatorCountAsync = ref.watch(translatorCountProvider);
    final AsyncValue<int> publisherCountAsync = ref.watch(publisherCountProvider);
    final AsyncValue<int> sequenceCountAsync = ref.watch(sequenceCountProvider);
    final AsyncValue<int> readerCountAsync = ref.watch(readerCountProvider);
    final AsyncValue<BookFairEventEntity> eventAsync = ref.watch(bookFairEventProvider);

    final int? bookCount = bookCountAsync.asData?.value;
    final int? workCount = workCountAsync.asData?.value;
    final int? authorCount = authorCountAsync.asData?.value;
    final int? translatorCount = translatorCountAsync.asData?.value;
    final int? publisherCount = publisherCountAsync.asData?.value;
    final int? sequenceCount = sequenceCountAsync.asData?.value;
    final int? readerCount = readerCountAsync.asData?.value;

    // Check visibility based on dates from event entity
    const bool isFairTileVisible = true;
    String? countdownText;

    eventAsync.whenData((BookFairEventEntity event) {
      final DateTime now = DateTime.now();

      if (now.isBefore(event.startDate)) {
        // Countdown to start
        final Duration diff = event.startDate.difference(now);
        if (diff.inDays >= 1) {
          countdownText = '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} to go';
        } else {
          countdownText = '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} to go';
        }
      } else if (now.isBefore(event.endDate)) {
        // Happening now!
        final Duration diff = event.endDate.difference(now);
        if (diff.inDays >= 1) {
          countdownText = '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} left';
        } else {
          countdownText = 'Live Now!';
        }
      } else {
        // Ended
        countdownText = 'Ended';
      }
    });

    // ── Layout helpers ─────────────────────────────────────────────────
    final int crossAxisCount = isExpanded ? 4 : (isCompact ? 2 : 3);
    final double cardAspectRatio = isCompact ? 1.0 : 0.95;
    final double maxWidth = isExpanded ? 960 : double.infinity;
    final EdgeInsets outerPadding = EdgeInsets.symmetric(
      horizontal: isCompact ? 16 : 24,
      vertical: isCompact ? 20 : 28,
    );

    // ── Entity cards ───────────────────────────────────────────────────
    final List<_CardDef> entityCards = <_CardDef>[
      _CardDef(
        title: _label(bookCount, 'Book'),
        icon: Icons.book_rounded,
        count: bookCount,
        route: '/books',
        colorVariant: DashboardCardColor.primary,
      ),
      _CardDef(
        title: _label(workCount, 'Work'),
        icon: Icons.article_rounded,
        count: workCount,
        route: '/works',
        colorVariant: DashboardCardColor.primary,
      ),
      _CardDef(
        title: _label(authorCount, 'Author'),
        icon: Icons.person_rounded,
        count: authorCount,
        route: '/authors',
        colorVariant: DashboardCardColor.primary,
      ),
      _CardDef(
        title: _label(translatorCount, 'Translator'),
        icon: Icons.translate_rounded,
        count: translatorCount,
        route: '/translators',
        colorVariant: DashboardCardColor.primary,
      ),
      _CardDef(
        title: _label(publisherCount, 'Publisher'),
        icon: Icons.business_rounded,
        count: publisherCount,
        route: '/publishers',
        colorVariant: DashboardCardColor.primary,
      ),
      _CardDef(
        title: _label(sequenceCount, 'Sequence'),
        icon: Icons.layers_rounded,
        count: sequenceCount,
        route: '/sequences',
        colorVariant: DashboardCardColor.primary,
      ),
      _CardDef(
        title: _label(readerCount, 'Reader'),
        icon: Icons.face_rounded,
        count: readerCount,
        route: '/readers',
        colorVariant: DashboardCardColor.primary,
      ),
    ];

    // ── Action cards (status + quality views) ──────────────────────────
    final List<_CardDef> actionCards = <_CardDef>[
      const _CardDef(
        title: 'Collection',
        icon: Icons.library_books_rounded,
        count: null,
        route: '/collection-status',
        colorVariant: DashboardCardColor.success,
      ),
      const _CardDef(
        title: 'Reading',
        icon: Icons.menu_book_rounded,
        count: null,
        route: '/reading-status',
        colorVariant: DashboardCardColor.blue,
      ),
      const _CardDef(
        title: 'Data Quality',
        icon: Icons.checklist_rounded,
        count: null,
        route: '/data-quality',
        colorVariant: DashboardCardColor.error,
      ),
      if (isFairTileVisible)
        _CardDef(
          title: eventAsync.value != null ? 'CIBF ${eventAsync.value!.year}' : 'CIBF',
          icon: Icons.festival_rounded,
          count: null,
          subtitle: countdownText,
          countdownTarget: eventAsync.value != null
              ? (DateTime.now().isBefore(eventAsync.value!.startDate)
                    ? eventAsync.value!.startDate
                    : eventAsync.value!.endDate)
              : null,
          countdownSuffix: 'TO GO',
          colorVariant: DashboardCardColor.purple,
          route: '/book-fair',
        ),
    ];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: <Widget>[
        SliverPadding(
          padding: outerPadding,
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // ── Entity grid ─────────────────────────────────────
                    Text(
                      'Library',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entityCards.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: cardAspectRatio,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final _CardDef c = entityCards[index];
                        return DashboardCard(
                          title: c.title,
                          icon: c.icon,
                          count: c.count,
                          colorVariant: c.colorVariant,
                          showLoader: true,
                          onTap: () => context.go(c.route),
                        );
                      },
                    ),
                    SizedBox(height: isCompact ? 28 : 36),

                    // ── Actions / Status / Quality ────────────────────────
                    Text(
                      'Manage',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: actionCards.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: cardAspectRatio,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final _CardDef c = actionCards[index];
                        return DashboardCard(
                          title: c.title,
                          icon: c.icon,
                          count: c.count,
                          subtitle: c.subtitle,
                          countdownTarget: c.countdownTarget,
                          countdownSuffix: c.countdownSuffix,
                          colorVariant: c.colorVariant,
                          onTap: () => context.go(c.route),
                        );
                      },
                    ),
                    SizedBox(height: isCompact ? 32 : 40),
                  ],
                ),
              ),
            ),
          ),
        ),
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

// ── Internal helpers ───────────────────────────────────────────────────────

class _CardDef {
  const _CardDef({
    required this.title,
    required this.icon,
    required this.count,
    required this.route,
    required this.colorVariant,
    this.subtitle,
    this.countdownTarget,
    this.countdownSuffix,
  });

  final String title;
  final IconData icon;
  final int? count;
  final String route;
  final DashboardCardColor colorVariant;
  final String? subtitle;
  final DateTime? countdownTarget;
  final String? countdownSuffix;
}
