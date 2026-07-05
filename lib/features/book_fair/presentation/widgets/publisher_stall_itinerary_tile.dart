import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_status_controller.dart';
import '../../../book/presentation/widgets/book_quick_info_dialog.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../domain/entities/book_fair_stall_entity.dart';

class PublisherStallItineraryTile extends ConsumerStatefulWidget {
  const PublisherStallItineraryTile({
    required this.publisher,
    required this.stall,
    required this.isVisited,
    required this.books,
    this.borderRadius,
    super.key,
  });

  final PublisherEntity publisher;
  final BookFairStallEntity stall;
  final bool isVisited;
  final List<BookEntity> books;
  final BorderRadius? borderRadius;

  @override
  ConsumerState<PublisherStallItineraryTile> createState() => _PublisherStallItineraryTileState();
}

class _PublisherStallItineraryTileState extends ConsumerState<PublisherStallItineraryTile> {
  bool _isExpanded = false;
  final Set<String> _checkedBookIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final Color purpleContainer = isDark
        ? const Color(0xFF4A148C).withValues(alpha: 0.18)
        : const Color(0xFFE1BEE7).withValues(alpha: 0.35);
    final Color onPurpleContainer = isDark ? const Color(0xFFE1BEE7) : const Color(0xFF4A148C);
    final Color purplePrimary = isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2);

    final bool hasBooks = widget.books.isNotEmpty;

    return Theme(
      // Remove default ExpansionTile divider lines
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        onExpansionChanged: (bool expanded) => setState(() => _isExpanded = expanded),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: EdgeInsets.zero,
        shape: const Border(),
        collapsedShape: const Border(),
        // Leading: Shop icon indicating completion status
        leading: FaIcon(
          FontAwesomeIcons.shop,
          size: 18,
          color: widget.isVisited
              ? colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
              : purplePrimary,
        ),
        title: Text(
          widget.stall.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            decoration: widget.isVisited ? TextDecoration.lineThrough : null,
            color: widget.isVisited
                ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                : colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.publisher.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: widget.isVisited
                    ? colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                    : colorScheme.onSurfaceVariant,
                decoration: widget.isVisited ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: widget.isVisited
                    ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                    : purpleContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.stall.stallNo,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.isVisited
                      ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                      : onPurpleContainer,
                ),
              ),
            ),
          ],
        ),
        trailing: hasBooks
            ? AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: FaIcon(FontAwesomeIcons.chevronDown, size: 14, color: purplePrimary),
              )
            : null,
        showTrailingIcon: hasBooks,
        children: hasBooks
            ? <Widget>[
                Container(
                  margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                  decoration: BoxDecoration(
                    color: purpleContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 4),
                      ...widget.books.map(
                        (BookEntity book) {
                          final bool isChecked = _checkedBookIds.contains(book.id);

                          return InkWell(
                            onTap: () => BookQuickInfoDialog.show(context, book.id),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: <Widget>[
                                  if (isChecked)
                                    IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.circleCheck,
                                        color: purplePrimary,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _checkedBookIds.remove(book.id);
                                        });
                                      },
                                      tooltip: 'Undo (Back to Shopping List)',
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                    )
                                  else
                                    IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.circle,
                                        color: purplePrimary.withValues(alpha: 0.6),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _checkedBookIds.add(book.id);
                                        });
                                      },
                                      tooltip: 'Mark as Collected',
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                    ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      book.title,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: isChecked
                                            ? onPurpleContainer.withValues(alpha: 0.5)
                                            : onPurpleContainer,
                                        fontWeight: FontWeight.w500,
                                        decoration: isChecked ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (_checkedBookIds.isNotEmpty) ...<Widget>[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Divider(height: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: purplePrimary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const FaIcon(FontAwesomeIcons.checkDouble, size: 12),
                              label: const Text(
                                'Complete Stall Shopping',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () async {
                                final List<String> toUpdate = _checkedBookIds.toList();
                                setState(() {
                                  _checkedBookIds.clear();
                                });
                                for (final String id in toUpdate) {
                                  final BookEntity book = widget.books.firstWhere((BookEntity b) => b.id == id);
                                  await ref
                                      .read(bookStatusControllerProvider.notifier)
                                      .changeCollectionStatus(
                                        book,
                                        CollectionStatus.collected,
                                        collectedDate: DateTime.now(),
                                      );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ]
            : const <Widget>[],
      ),
    );
  }
}
