import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../../reader/domain/entities/reader_entity.dart';
import '../../../reader/presentation/providers/reader_provider.dart';
import '../../domain/entities/book_entity.dart';
import '../providers/book_provider.dart';
import '../providers/book_status_controller.dart';
import '../widgets/status_action_chip.dart';
import '../widgets/status_date_field.dart';

class BookCollectionStatusManagePage extends ConsumerStatefulWidget {
  const BookCollectionStatusManagePage({super.key});

  @override
  ConsumerState<BookCollectionStatusManagePage> createState() =>
      _BookCollectionStatusManagePageState();
}

class _BookCollectionStatusManagePageState extends ConsumerState<BookCollectionStatusManagePage>
    with SingleTickerProviderStateMixin {
  static const List<CollectionStatus> _statuses = CollectionStatus.values;
  late final TabController _tabController;

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
    final ColorScheme colorScheme = theme.colorScheme;
    final Map<CollectionStatus, int>? collectionStatusMap = ref.watch(
      booksByCollectionStatusProvider,
    );

    final bool isDark = theme.brightness == Brightness.dark;
    final Color greenText = isDark ? const Color(0xFFA5D6A7) : const Color(0xFF1B5E20);
    final Color greenBadgeBg = isDark ? const Color(0xFF0F5223) : const Color(0xFFC8E6C9);
    final Color greenOnBadgeBg = isDark ? const Color(0xFFA5D6A7) : const Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: greenText,
        title: const Text('Collection Status'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: greenText,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: greenText,
          dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.4),
          tabs: _statuses
              .map(
                (CollectionStatus s) => Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(s.clientValue),
                      if (collectionStatusMap == null)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                greenText.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        )
                      else if ((collectionStatusMap[s] ?? 0) > 0) ...<Widget>[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: greenBadgeBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${collectionStatusMap[s]}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: greenOnBadgeBg,
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

class _StatusTabView extends ConsumerWidget {
  const _StatusTabView({required this.status});

  final CollectionStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<BookEntity>? allBooks = ref.watch(booksStreamProvider).value;
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

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
            FaIcon(
              FontAwesomeIcons.boxesStacked,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No books with "${status.clientValue}" status',
              style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
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

class _CollectionBookTile extends ConsumerWidget {
  const _CollectionBookTile({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isLoading = ref.watch(bookStatusControllerProvider);
    final String? publisherName = book.publisherId != null
        ? ref.watch(publisherProvider(book.publisherId!)).value?.name
        : null;
    final CollectionStatus status = book.collectionStatus;

    final bool isDark = theme.brightness == Brightness.dark;
    final Color greenContainer = isDark
        ? const Color(0xFF0F5223).withValues(alpha: 0.18)
        : const Color(0xFFC8E6C9).withValues(alpha: 0.18);
    final Color greenText = isDark ? const Color(0xFFA5D6A7) : const Color(0xFF1B5E20);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: greenText.withValues(alpha: 0.3)),
      ),
      color: greenContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              book.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (publisherName != null) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                publisherName,
                style: theme.textTheme.bodySmall?.copyWith(color: greenText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildActions(context, ref, status, colorScheme, isLoading),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    WidgetRef ref,
    CollectionStatus status,
    ColorScheme colorScheme,
    bool isLoading,
  ) {
    final List<Widget> actions = <Widget>[];
    final BookStatusController ctrl = ref.read(bookStatusControllerProvider.notifier);

    switch (status) {
      case CollectionStatus.announced:
        actions.add(
          StatusActionChip(
            label: 'Shopping List',
            icon: FontAwesomeIcons.cartShopping,
            color: colorScheme.primary,
            onTap: isLoading
                ? null
                : () => ctrl.changeCollectionStatus(book, CollectionStatus.shoppingList),
          ),
        );
      case CollectionStatus.shoppingList:
        actions.add(
          StatusActionChip(
            label: 'Collect',
            icon: FontAwesomeIcons.circleCheck,
            color: colorScheme.primary,
            onTap: isLoading ? null : () => _showCollectDialog(context, ref, book),
          ),
        );
        actions.add(
          StatusActionChip(
            label: 'Order Online',
            icon: FontAwesomeIcons.truck,
            color: colorScheme.primary,
            onTap: isLoading
                ? null
                : () => ctrl.changeCollectionStatus(book, CollectionStatus.onTheWay),
          ),
        );
      case CollectionStatus.onTheWay:
        actions.add(
          StatusActionChip(
            label: 'Collect',
            icon: FontAwesomeIcons.circleCheck,
            color: colorScheme.primary,
            onTap: isLoading ? null : () => _showCollectDialog(context, ref, book),
          ),
        );
      case CollectionStatus.collected:
        actions.add(
          StatusActionChip(
            label: 'Lend',
            icon: FontAwesomeIcons.handshake,
            color: colorScheme.primary,
            onTap: isLoading ? null : () => _showLendDialog(context, ref, book),
          ),
        );
      case CollectionStatus.lended:
        actions.add(
          StatusActionChip(
            label: 'Return',
            icon: FontAwesomeIcons.arrowRotateLeft,
            color: colorScheme.primary,
            onTap: isLoading
                ? null
                : () => ctrl.changeCollectionStatus(book, CollectionStatus.collected),
          ),
        );
      case CollectionStatus.outOfPrint:
        actions.add(
          StatusActionChip(
            label: 'Announce',
            icon: FontAwesomeIcons.bullhorn,
            color: colorScheme.primary,
            onTap: isLoading
                ? null
                : () => ctrl.changeCollectionStatus(book, CollectionStatus.announced),
          ),
        );
    }

    return actions;
  }

  Future<void> _showCollectDialog(BuildContext context, WidgetRef ref, BookEntity book) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => _CollectDialog(book: book),
    );
  }

  Future<void> _showLendDialog(BuildContext context, WidgetRef ref, BookEntity book) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => _LendDialog(book: book),
    );
  }
}

class _CollectDialog extends ConsumerStatefulWidget {
  const _CollectDialog({required this.book});
  final BookEntity book;

  @override
  ConsumerState<_CollectDialog> createState() => _CollectDialogState();
}

class _CollectDialogState extends ConsumerState<_CollectDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime _collectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);

    return AlertDialog(
      title: const Text('Collect'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
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
              FormField<DateTime>(
                initialValue: _collectedDate,
                validator: (DateTime? val) {
                  if (val == null) {
                    return 'Collected date is required';
                  }

                  return null;
                },
                builder: (FormFieldState<DateTime> state) => StatusDateField(
                  label: 'Collected Date',
                  value: _collectedDate,
                  onChanged: (DateTime d) {
                    setState(() => _collectedDate = d);
                    state.didChange(d);
                    _formKey.currentState?.validate();
                  },
                  theme: theme,
                  errorText: state.errorText,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: _isLoading ? null : () => context.pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Collect'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    await ref
        .read(bookStatusControllerProvider.notifier)
        .changeCollectionStatus(
          widget.book,
          CollectionStatus.collected,
          collectedDate: _collectedDate,
        );

    if (mounted) {
      context.pop();
    }
  }
}

class _LendDialog extends ConsumerStatefulWidget {
  const _LendDialog({required this.book});
  final BookEntity book;

  @override
  ConsumerState<_LendDialog> createState() => _LendDialogState();
}

class _LendDialogState extends ConsumerState<_LendDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedReaderId;
  DateTime _lendedDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final List<ReaderEntity>? readers = ref.watch(readersStreamProvider).value;

    return AlertDialog(
      title: const Text('Lend'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
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
              DropdownButtonFormField<String>(
                value: _selectedReaderId,
                decoration: InputDecoration(
                  labelText: 'Reader',
                  prefixIcon: const FaIcon(FontAwesomeIcons.smile),
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
                validator: (String? v) => v == null ? 'Please select a reader' : null,
                onChanged: (String? v) => setState(() => _selectedReaderId = v),
              ),
              const SizedBox(height: 16),
              FormField<DateTime>(
                initialValue: _lendedDate,
                validator: (DateTime? val) {
                  if (val == null) {
                    return 'Lended date is required';
                  }

                  return null;
                },
                builder: (FormFieldState<DateTime> state) => StatusDateField(
                  label: 'Lended Date',
                  value: _lendedDate,
                  onChanged: (DateTime d) {
                    setState(() => _lendedDate = d);
                    state.didChange(d);
                    _formKey.currentState?.validate();
                  },
                  theme: theme,
                  errorText: state.errorText,
                ),
              ),
              const SizedBox(height: 12),
              FormField<DateTime>(
                initialValue: _dueDate,
                validator: (DateTime? val) {
                  if (val == null) {
                    return 'Due date is required';
                  }

                  if (val.isBefore(_lendedDate) || val.isAtSameMomentAs(_lendedDate)) {
                    return 'Due date must be after lended date';
                  }

                  return null;
                },
                builder: (FormFieldState<DateTime> state) => StatusDateField(
                  label: 'Due Date',
                  value: _dueDate,
                  onChanged: (DateTime d) {
                    setState(() => _dueDate = d);
                    state.didChange(d);
                    _formKey.currentState?.validate();
                  },
                  theme: theme,
                  errorText: state.errorText,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: _isLoading ? null : () => context.pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    await ref
        .read(bookStatusControllerProvider.notifier)
        .changeCollectionStatus(
          widget.book,
          CollectionStatus.lended,
          readerId: _selectedReaderId,
          lendedDate: _lendedDate,
          dueDate: _dueDate,
        );

    if (mounted) {
      context.pop();
    }
  }
}
