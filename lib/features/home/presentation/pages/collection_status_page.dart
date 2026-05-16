import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../book/presentation/providers/book_status_controller.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../../reader/domain/entities/reader_entity.dart';
import '../../../reader/presentation/providers/reader_provider.dart';

// ── Date formatter ─────────────────────────────────────────────────────────

final DateFormat _dateFmt = DateFormat('d MMM yyyy');

class CollectionStatusPage extends ConsumerStatefulWidget {
  const CollectionStatusPage({super.key});

  @override
  ConsumerState<CollectionStatusPage> createState() => _CollectionStatusPageState();
}

class _CollectionStatusPageState extends ConsumerState<CollectionStatusPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const List<CollectionStatus> _statuses = CollectionStatus.values;

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
    final Map<CollectionStatus, int>? byColl = ref.watch(booksByCollectionStatusProvider);

    final bool isDark = theme.brightness == Brightness.dark;
    final Color successColor = isDark ? const Color(0xFFA5D6A7) : const Color(0xFF1B5E20);
    final Color successContainer = isDark ? const Color(0xFF0F5223) : const Color(0xFFC8E6C9);
    final Color onSuccessContainer = isDark ? const Color(0xFFE8F5E9) : const Color(0xFF000000);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: successColor,
        title: const Text('Collection Status'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: successColor,
          unselectedLabelColor: cs.onSurfaceVariant,
          indicatorColor: successColor,
          dividerColor: cs.outlineVariant.withValues(alpha: 0.4),
          tabs: _statuses
              .map(
                (CollectionStatus s) => Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(s.clientValue),
                      if (byColl == null)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                successColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        )
                      else if ((byColl[s] ?? 0) > 0) ...<Widget>[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: successContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${byColl[s]}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: onSuccessContainer,
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
        children: _statuses.map((CollectionStatus s) => _StatusTabView(status: s)).toList(),
      ),
    );
  }
}

// ── Tab content ─────────────────────────────────────────────────────────────

class _StatusTabView extends ConsumerWidget {
  const _StatusTabView({required this.status});

  final CollectionStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<BookEntity>? allBooks = ref.watch(booksStreamProvider).value;
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme cs = theme.colorScheme;

    if (allBooks == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<BookEntity> books = allBooks
        .where((BookEntity b) => b.collectionStatus == status)
        .toList();

    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.inbox_rounded, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
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
      itemBuilder: (BuildContext context, int index) => _CollectionBookTile(book: books[index]),
    );
  }
}

// ── Book tile ────────────────────────────────────────────────────────────────

class _CollectionBookTile extends ConsumerWidget {
  const _CollectionBookTile({required this.book});

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

    final CollectionStatus status = book.collectionStatus;

    final bool isDark = theme.brightness == Brightness.dark;
    final Color successColor = isDark ? const Color(0xFFA5D6A7) : const Color(0xFF1B5E20);
    final Color successContainer = isDark ? const Color(0xFF0F5223) : const Color(0xFFC8E6C9);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      color: successContainer.withValues(alpha: 0.18),
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
                style: theme.textTheme.bodySmall?.copyWith(color: successColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),

            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildActions(context, ref, successColor, theme, isLoading, status),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    WidgetRef ref,
    Color successColor,
    ThemeData theme,
    bool isLoading,
    CollectionStatus status,
  ) {
    final List<Widget> actions = <Widget>[];
    final BookStatusController ctrl = ref.read(bookStatusControllerProvider.notifier);

    switch (status) {
      case CollectionStatus.announced:
        actions.add(
          _ActionChip(
            label: 'Move to Shopping List',
            icon: Icons.shopping_cart_outlined,
            color: successColor,
            onTap: isLoading
                ? null
                : () => ctrl.setCollectionStatus(book, CollectionStatus.shoppingList),
          ),
        );

      case CollectionStatus.shoppingList:
        actions.add(
          _ActionChip(
            label: 'Mark as Collected',
            icon: Icons.check_circle_outline_rounded,
            color: successColor,
            onTap: isLoading
                ? null
                : () => ctrl.setCollectionStatus(book, CollectionStatus.collected),
          ),
        );

      case CollectionStatus.collected:
        actions.add(
          _ActionChip(
            label: 'Lend Out',
            icon: Icons.swap_horiz_rounded,
            color: successColor,
            onTap: isLoading ? null : () => _showLendDialog(context, ref, book),
          ),
        );

      case CollectionStatus.lended:
        actions.add(
          _ActionChip(
            label: 'Mark as Returned',
            icon: Icons.undo_rounded,
            color: successColor,
            onTap: isLoading
                ? null
                : () => ctrl.setCollectionStatus(book, CollectionStatus.collected),
          ),
        );

      case CollectionStatus.outOfPrint:
        actions.add(
          _ActionChip(
            label: 'Back to Announced',
            icon: Icons.campaign_outlined,
            color: successColor,
            onTap: isLoading
                ? null
                : () => ctrl.setCollectionStatus(book, CollectionStatus.announced),
          ),
        );
    }

    return actions;
  }

  Future<void> _showLendDialog(BuildContext context, WidgetRef ref, BookEntity book) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => _LendDialog(book: book),
    );
  }
}

// ── Lend dialog ──────────────────────────────────────────────────────────────

class _LendDialog extends ConsumerStatefulWidget {
  const _LendDialog({required this.book});
  final BookEntity book;

  @override
  ConsumerState<_LendDialog> createState() => _LendDialogState();
}

class _LendDialogState extends ConsumerState<_LendDialog> {
  String? _selectedReaderId;
  DateTime _lendedDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final List<ReaderEntity>? readers = ref.watch(readersStreamProvider).value;

    return AlertDialog(
      title: const Text('Lend Book'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.book.title,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),

            // Reader selector
            DropdownButtonFormField<String>(
              value: _selectedReaderId,
              decoration: InputDecoration(
                labelText: 'Reader *',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items:
                  readers
                      ?.map(
                        (ReaderEntity r) =>
                            DropdownMenuItem<String>(value: r.id, child: Text(r.name)),
                      )
                      .toList() ??
                  <DropdownMenuItem<String>>[],
              onChanged: (String? v) => setState(() => _selectedReaderId = v),
            ),
            const SizedBox(height: 16),

            // Lended date
            _DateField(
              label: 'Lended Date',
              value: _lendedDate,
              onChanged: (DateTime d) => setState(() => _lendedDate = d),
              colorScheme: cs,
              theme: theme,
            ),
            const SizedBox(height: 12),

            // Due date
            _DateField(
              label: 'Due Date',
              value: _dueDate,
              onChanged: (DateTime d) => setState(() => _dueDate = d),
              colorScheme: cs,
              theme: theme,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedReaderId == null || _isLoading ? null : _lend,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Lend'),
        ),
      ],
    );
  }

  Future<void> _lend() async {
    if (_selectedReaderId == null) {
      return;
    }
    setState(() => _isLoading = true);

    await ref
        .read(bookStatusControllerProvider.notifier)
        .lendBook(
          widget.book,
          readerId: _selectedReaderId!,
          lendedDate: _lendedDate,
          dueDate: _dueDate,
        );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

// ── Date field helper ────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.colorScheme,
    required this.theme,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: value,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        onChanged(picked);
      }
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(_dateFmt.format(value), style: theme.textTheme.bodyMedium),
    ),
  );
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
