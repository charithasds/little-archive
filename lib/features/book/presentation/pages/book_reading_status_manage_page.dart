import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../domain/entities/book_entity.dart';
import '../providers/book_provider.dart';
import '../providers/book_status_controller.dart';
import '../widgets/status_action_chip.dart';
import '../widgets/status_date_field.dart';

class BookReadingStatusManagePage extends ConsumerStatefulWidget {
  const BookReadingStatusManagePage({super.key});

  @override
  ConsumerState<BookReadingStatusManagePage> createState() => _BookReadingStatusManagePageState();
}

class _BookReadingStatusManagePageState extends ConsumerState<BookReadingStatusManagePage>
    with SingleTickerProviderStateMixin {
  static const List<ReadingStatus> _statuses = ReadingStatus.values;
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
    final Map<ReadingStatus, int>? readingStatusMap = ref.watch(booksByReadingStatusProvider);

    final bool isDark = theme.brightness == Brightness.dark;
    final Color blueText = isDark ? const Color(0xFF90CAF9) : const Color(0xFF0D47A1);
    final Color blueBadgeBg = isDark ? const Color(0xFF0D47A1) : const Color(0xFFBBDEFB);
    final Color blueOnBadgeBg = isDark ? const Color(0xFF90CAF9) : const Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: blueText,
        title: const Text('Reading Status'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: blueText,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: blueText,
          dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.4),
          tabs: _statuses
              .map(
                (ReadingStatus s) => Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(s.clientValue),
                      if (readingStatusMap == null)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                blueText.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        )
                      else if ((readingStatusMap[s] ?? 0) > 0) ...<Widget>[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: blueBadgeBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${readingStatusMap[s]}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: blueOnBadgeBg,
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

class _ReadingTabView extends ConsumerWidget {
  const _ReadingTabView({required this.status});

  final ReadingStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<BookEntity>? allBooks = ref.watch(booksStreamProvider).value;
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

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
            FaIcon(
              FontAwesomeIcons.bookOpen,
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
      itemBuilder: (BuildContext context, int index) => _ReadingBookTile(book: books[index]),
    );
  }
}

class _ReadingBookTile extends ConsumerWidget {
  const _ReadingBookTile({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isLoading = ref.watch(bookStatusControllerProvider);
    final String? publisherName = book.publisherId != null
        ? ref.watch(publisherProvider(book.publisherId!)).value?.name
        : null;
    final ReadingStatus status = book.readingStatus;

    final bool isDark = theme.brightness == Brightness.dark;
    final Color blueContainer = isDark
        ? const Color(0xFF0D47A1).withValues(alpha: 0.18)
        : const Color(0xFFBBDEFB).withValues(alpha: 0.18);
    final Color blueText = isDark ? const Color(0xFF90CAF9) : const Color(0xFF0D47A1);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: blueText.withValues(alpha: 0.3)),
      ),
      color: blueContainer,
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
                style: theme.textTheme.bodySmall?.copyWith(color: blueText),
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
    ReadingStatus status,
    ColorScheme colorScheme,
    bool isLoading,
  ) {
    final List<Widget> actions = <Widget>[];
    final BookStatusController ctrl = ref.read(bookStatusControllerProvider.notifier);

    switch (status) {
      case ReadingStatus.notStarted:
        actions.add(
          StatusActionChip(
            label: 'Start Reading',
            icon: FontAwesomeIcons.play,
            color: colorScheme.tertiary,
            onTap: isLoading ? null : () => ctrl.changeReadingStatus(book, ReadingStatus.reading),
          ),
        );
      case ReadingStatus.reading:
        actions.add(
          StatusActionChip(
            label: 'Pause',
            icon: FontAwesomeIcons.pause,
            color: colorScheme.tertiary,
            onTap: isLoading ? null : () => _showPauseDialog(context, ref, book),
          ),
        );
        actions.add(
          StatusActionChip(
            label: 'Complete',
            icon: FontAwesomeIcons.circleCheck,
            color: colorScheme.tertiary,
            onTap: isLoading ? null : () => _showCompleteDialog(context, ref, book),
          ),
        );
        actions.add(
          StatusActionChip(
            label: 'Abandon',
            icon: FontAwesomeIcons.xmark,
            color: colorScheme.error,
            onTap: isLoading ? null : () => ctrl.changeReadingStatus(book, ReadingStatus.abandoned),
          ),
        );
      case ReadingStatus.paused:
        actions.add(
          StatusActionChip(
            label: 'Resume',
            icon: FontAwesomeIcons.play,
            color: colorScheme.tertiary,
            onTap: isLoading ? null : () => ctrl.changeReadingStatus(book, ReadingStatus.reading),
          ),
        );
        actions.add(
          StatusActionChip(
            label: 'Abandon',
            icon: FontAwesomeIcons.xmark,
            color: colorScheme.error,
            onTap: isLoading ? null : () => ctrl.changeReadingStatus(book, ReadingStatus.abandoned),
          ),
        );
      case ReadingStatus.completed:
        actions.add(
          StatusActionChip(
            label: 'Re-read',
            icon: FontAwesomeIcons.rotateLeft,
            color: colorScheme.tertiary,
            onTap: isLoading ? null : () => ctrl.changeReadingStatus(book, ReadingStatus.reading),
          ),
        );
      case ReadingStatus.abandoned:
        actions.add(
          StatusActionChip(
            label: 'Restart',
            icon: FontAwesomeIcons.rotateRight,
            color: colorScheme.tertiary,
            onTap: isLoading
                ? null
                : () => ctrl.changeReadingStatus(book, ReadingStatus.notStarted),
          ),
        );
    }

    return actions;
  }

  Future<void> _showPauseDialog(BuildContext context, WidgetRef ref, BookEntity book) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => _PauseDialog(book: book),
    );
  }

  Future<void> _showCompleteDialog(BuildContext context, WidgetRef ref, BookEntity book) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => _CompleteDialog(book: book),
    );
  }
}

class _PauseDialog extends ConsumerStatefulWidget {
  const _PauseDialog({required this.book});
  final BookEntity book;

  @override
  ConsumerState<_PauseDialog> createState() => _PauseDialogState();
}

class _PauseDialogState extends ConsumerState<_PauseDialog> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.book.pausedPage != null) {
      _controller.text = widget.book.pausedPage.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);

    return AlertDialog(
      title: const Text('Pause'),
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
              TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Paused Page',
                  prefixIcon: const FaIcon(FontAwesomeIcons.bookmark),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixText: widget.book.noOfPages != null ? '/ ${widget.book.noOfPages}' : null,
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a page number';
                  }

                  final int? page = int.tryParse(value);

                  if (page == null || page <= 0) {
                    return 'Enter a valid page number';
                  }

                  if (widget.book.noOfPages != null && page > widget.book.noOfPages!) {
                    return 'Cannot exceed total pages (${widget.book.noOfPages})';
                  }

                  return null;
                },
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
              : const Text('Pause'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final int page = int.parse(_controller.text.trim());

    setState(() => _isLoading = true);

    await ref
        .read(bookStatusControllerProvider.notifier)
        .changeReadingStatus(widget.book, ReadingStatus.paused, pausedPage: page);

    if (mounted) {
      context.pop();
    }
  }
}

class _CompleteDialog extends ConsumerStatefulWidget {
  const _CompleteDialog({required this.book});
  final BookEntity book;

  @override
  ConsumerState<_CompleteDialog> createState() => _CompleteDialogState();
}

class _CompleteDialogState extends ConsumerState<_CompleteDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime _completedDate = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);

    return AlertDialog(
      title: const Text('Complete'),
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
                initialValue: _completedDate,
                validator: (DateTime? val) {
                  if (val == null) {
                    return 'Completed date is required';
                  }

                  return null;
                },
                builder: (FormFieldState<DateTime> state) => StatusDateField(
                  label: 'Completed Date',
                  value: _completedDate,
                  onChanged: (DateTime d) {
                    setState(() => _completedDate = d);
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
              : const Text('Complete'),
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
        .changeReadingStatus(widget.book, ReadingStatus.completed, completedDate: _completedDate);

    if (mounted) {
      context.pop();
    }
  }
}
