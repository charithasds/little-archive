import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../book/presentation/providers/book_status_controller.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';

class ReadingStatusPage extends ConsumerStatefulWidget {
  const ReadingStatusPage({super.key});

  @override
  ConsumerState<ReadingStatusPage> createState() => _ReadingStatusPageState();
}

class _ReadingStatusPageState extends ConsumerState<ReadingStatusPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const List<ReadingStatus> _statuses = ReadingStatus.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme cs = theme.colorScheme;
    final Map<ReadingStatus, int>? byRead = ref.watch(booksByReadingStatusProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: cs.tertiary,
        title: const Text('Reading Status'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: cs.tertiary,
          unselectedLabelColor: cs.onSurfaceVariant,
          indicatorColor: cs.tertiary,
          dividerColor: cs.outlineVariant.withValues(alpha: 0.4),
          tabs: _statuses
              .map(
                (ReadingStatus s) => Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(s.clientValue),
                      if (byRead != null && (byRead[s] ?? 0) > 0) ...<Widget>[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: cs.tertiaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${byRead[s]}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onTertiaryContainer,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statuses.map((ReadingStatus s) => _ReadingTabView(status: s)).toList(),
      ),
    );
  }
}

// ── Tab content ─────────────────────────────────────────────────────────────

class _ReadingTabView extends ConsumerWidget {
  const _ReadingTabView({required this.status});

  final ReadingStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<BookEntity>? allBooks = ref.watch(booksStreamProvider).value;
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme cs = theme.colorScheme;

    if (allBooks == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<BookEntity> books = allBooks
        .where((BookEntity b) => b.readingStatus == status)
        .toList();

    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No books with "${status.clientValue}" status',
              style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: books.length,
      itemBuilder: (BuildContext context, int index) => _ReadingBookTile(book: books[index]),
    );
  }
}

// ── Book tile ────────────────────────────────────────────────────────────────

class _ReadingBookTile extends ConsumerWidget {
  const _ReadingBookTile({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme cs = theme.colorScheme;
    final bool isLoading = ref.watch(bookStatusControllerProvider);

    // Publisher name lookup
    final String? publisherName = book.publisherId != null
        ? ref.watch(publisherProvider(book.publisherId!)).value?.name
        : null;

    final ReadingStatus status = book.readingStatus;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      color: cs.tertiaryContainer.withValues(alpha: 0.18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Title + Publisher row
            Text(
              book.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (publisherName != null) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                publisherName,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.tertiary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),

            // Action buttons
            Wrap(spacing: 8, runSpacing: 8, children: _buildActions(cs, ref, isLoading, status)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(ColorScheme cs, WidgetRef ref, bool isLoading, ReadingStatus status) {
    final List<Widget> actions = <Widget>[];
    final BookStatusController ctrl = ref.read(bookStatusControllerProvider.notifier);

    switch (status) {
      case ReadingStatus.notStarted:
        actions.add(
          _ActionChip(
            label: 'Start Reading',
            icon: Icons.play_arrow_rounded,
            color: cs.tertiary,
            onTap: isLoading ? null : () => ctrl.setReadingStatus(book, ReadingStatus.reading),
          ),
        );

      case ReadingStatus.reading:
        actions.add(
          _ActionChip(
            label: 'Pause',
            icon: Icons.pause_circle_outline_rounded,
            color: cs.tertiary,
            onTap: isLoading ? null : () => ctrl.setReadingStatus(book, ReadingStatus.paused),
          ),
        );
        actions.add(
          _ActionChip(
            label: 'Mark Complete',
            icon: Icons.check_circle_outline_rounded,
            color: cs.tertiary,
            onTap: isLoading ? null : () => ctrl.setReadingStatus(book, ReadingStatus.completed),
          ),
        );
        actions.add(
          _ActionChip(
            label: 'Abandon',
            icon: Icons.close_rounded,
            color: cs.error,
            onTap: isLoading ? null : () => ctrl.setReadingStatus(book, ReadingStatus.abandoned),
          ),
        );

      case ReadingStatus.paused:
        actions.add(
          _ActionChip(
            label: 'Resume',
            icon: Icons.play_arrow_rounded,
            color: cs.tertiary,
            onTap: isLoading ? null : () => ctrl.setReadingStatus(book, ReadingStatus.reading),
          ),
        );
        actions.add(
          _ActionChip(
            label: 'Abandon',
            icon: Icons.close_rounded,
            color: cs.error,
            onTap: isLoading ? null : () => ctrl.setReadingStatus(book, ReadingStatus.abandoned),
          ),
        );

      case ReadingStatus.completed:
        actions.add(
          _ActionChip(
            label: 'Re-read',
            icon: Icons.replay_rounded,
            color: cs.tertiary,
            onTap: isLoading ? null : () => ctrl.setReadingStatus(book, ReadingStatus.reading),
          ),
        );

      case ReadingStatus.abandoned:
        actions.add(
          _ActionChip(
            label: 'Restart',
            icon: Icons.refresh_rounded,
            color: cs.tertiary,
            onTap: isLoading ? null : () => ctrl.setReadingStatus(book, ReadingStatus.notStarted),
          ),
        );
    }

    return actions;
  }
}

// ── Action chip ──────────────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
    avatar: Icon(icon, size: 16, color: color),
    label: Text(label),
    labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    backgroundColor: color.withValues(alpha: 0.1),
    side: BorderSide(color: color.withValues(alpha: 0.3)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    onPressed: onTap,
  );
}
