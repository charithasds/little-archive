import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../domain/entities/book_fair_stall_entity.dart';
import 'publisher_stall_itinerary_tile.dart';

/// Legacy pair kept for backward compatibility where needed.
class PublisherStallPair {
  PublisherStallPair(this.publisher, this.stall);

  final PublisherEntity publisher;
  final BookFairStallEntity stall;
}

/// Issue #5: A stall that has multiple publishers mapped to it.
/// All publishers sharing the same stall are grouped here so the stall
/// appears exactly once in the shopping plan.
class StallGroup {
  StallGroup({required this.stall, required this.publishers});

  final BookFairStallEntity stall;
  final List<PublisherEntity> publishers;
}

class BookFairHallGroupCard extends ConsumerWidget {
  const BookFairHallGroupCard({
    required this.hallId,
    required this.stallGroups,
    super.key,
  });

  final String hallId;
  final List<StallGroup> stallGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    // Only shopping-list books — completed books are no longer shown.
    final List<BookEntity> allBooks =
        ref.watch(booksStreamProvider).value ?? <BookEntity>[];
    final List<BookEntity> shoppingListBooks = allBooks
        .where((BookEntity b) => b.collectionStatus == CollectionStatus.shoppingList)
        .toList();

    final Color purpleContainer = isDark
        ? const Color(0xFF4A148C).withValues(alpha: 0.18)
        : const Color(0xFFE1BEE7).withValues(alpha: 0.35);
    final Color onPurpleContainer =
        isDark ? const Color(0xFFE1BEE7) : const Color(0xFF4A148C);
    final Color purplePrimary =
        isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2);

    // Pre-compute books per stall and filter out stalls with no remaining
    // shopping-list books — completed stalls are removed, not crossed off.
    final List<({StallGroup group, List<BookEntity> books})> activeGroups =
        stallGroups.map((StallGroup group) {
      final Set<String> publisherIds =
          group.publishers.map((PublisherEntity p) => p.id).toSet();
      final List<BookEntity> stallBooks = shoppingListBooks
          .where((BookEntity b) => publisherIds.contains(b.publisherId))
          .toList();
      return (group: group, books: stallBooks);
    }).where((({StallGroup group, List<BookEntity> books}) e) => e.books.isNotEmpty).toList();

    // If all stalls in this hall are done, hide the entire hall card.
    if (activeGroups.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: purplePrimary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: <Widget>[
                FaIcon(FontAwesomeIcons.building, size: 20, color: purplePrimary),
                const SizedBox(width: 8),
                Text(
                  'Hall $hallId',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: purplePrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: purpleContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    // Badge shows remaining stalls, not total.
                    '${activeGroups.length} ${activeGroups.length == 1 ? 'stall' : 'stalls'}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: onPurpleContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: activeGroups.length,
            separatorBuilder: (BuildContext context, int i) =>
                const Divider(height: 1, indent: 56),
            itemBuilder: (BuildContext context, int i) {
              final StallGroup group = activeGroups[i].group;
              final List<BookEntity> stallBooks = activeGroups[i].books;

              return PublisherStallItineraryTile(
                publishers: group.publishers,
                stall: group.stall,
                books: stallBooks,
                borderRadius: i == activeGroups.length - 1
                    ? const BorderRadius.vertical(bottom: Radius.circular(20))
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
