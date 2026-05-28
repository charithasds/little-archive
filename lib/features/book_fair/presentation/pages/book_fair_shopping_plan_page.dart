import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/presentation/providers/user_profile_provider.dart';
import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/presentation/routes/router_service.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../domain/entities/book_fair_event_entity.dart';
import '../../domain/entities/book_fair_stall_entity.dart';
import '../providers/book_fair_event_provider.dart';
import '../widgets/book_fair_hall_group_card.dart';
import '../widgets/book_fair_progress_card.dart';

class BookFairShoppingPlanPage extends ConsumerWidget {
  const BookFairShoppingPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<BookFairEventEntity> eventAsync = ref.watch(bookFairEventProvider);
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return eventAsync.when(
      data: (BookFairEventEntity event) => _BookFairShoppingPlanView(
        event: event,
        onEditMappings: () {
          ref.read(goRouterProvider).go('/book-fair');
          ref.read(userProfileControllerProvider.notifier).updateLastConfiguredFairId(null);
        },
      ),
      loading: () => Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(title: const Text('CIBF Shopping Plan')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace? stack) => Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load plan', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(error.toString(), style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookFairShoppingPlanView extends ConsumerStatefulWidget {
  const _BookFairShoppingPlanView({required this.event, required this.onEditMappings});

  final BookFairEventEntity event;
  final VoidCallback onEditMappings;

  @override
  ConsumerState<_BookFairShoppingPlanView> createState() => _BookFairShoppingPlanViewState();
}

class _BookFairShoppingPlanViewState extends ConsumerState<_BookFairShoppingPlanView> {
  final Set<String> _visitedStalls = <String>{};

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color purpleContainer = isDark
        ? const Color(0xFF4A148C).withValues(alpha: 0.18)
        : const Color(0xFFE1BEE7).withValues(alpha: 0.35);
    final Color purplePrimary = isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2);
    final Color onPurplePrimary = isDark ? const Color(0xFF311B92) : Colors.white;
    final List<PublisherEntity> publishers =
        ref.watch(publishersStreamProvider).value ?? <PublisherEntity>[];
    final List<BookEntity> books = ref.watch(booksStreamProvider).value ?? <BookEntity>[];
    final Set<String> publisherIdsInShoppingList = books
        .where(
          (BookEntity b) =>
              b.collectionStatus == CollectionStatus.shoppingList && b.publisherId != null,
        )
        .map((BookEntity b) => b.publisherId!)
        .toSet();
    final List<PublisherEntity> mapped = publishers.where((PublisherEntity p) {
      final String? bookFairPublisherId = p.bookFairPublisherId;
      final bool hasStallMapped =
          bookFairPublisherId != null &&
          bookFairPublisherId.startsWith('CIBF_${widget.event.year}_');
      final bool hasBookInShoppingList = publisherIdsInShoppingList.contains(p.id);

      return hasStallMapped && hasBookInShoppingList;
    }).toList();

    final List<PublisherEntity> unmappedInShoppingList = publishers.where((PublisherEntity p) {
      final String? bookFairPublisherId = p.bookFairPublisherId;
      final bool isConfigurationRequired =
          bookFairPublisherId != 'none' &&
          (bookFairPublisherId == null ||
           !bookFairPublisherId.startsWith('CIBF_${widget.event.year}_'));
      final bool hasBookInShoppingList = publisherIdsInShoppingList.contains(p.id);

      return hasBookInShoppingList && isConfigurationRequired;
    }).toList();

    if (unmappedInShoppingList.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(goRouterProvider).go('/book-fair');
        ref.read(userProfileControllerProvider.notifier).updateLastConfiguredFairId(null);
      });

      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (mapped.isEmpty) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text('CIBF ${widget.event.year} Plan'),
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: purpleContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.explore_outlined, size: 64, color: purplePrimary),
                ),
                const SizedBox(height: 24),
                Text(
                  'Your Shopping Plan is Empty',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Map your local publishers to the CIBF stall directory to automatically compile your Hall-by-Hall route.',
                  style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purplePrimary,
                    foregroundColor: onPurplePrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Start Setup Wizard'),
                  onPressed: widget.onEditMappings,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final List<PublisherStallPair> pairs = mapped.map((PublisherEntity p) {
      final String stallId = p.bookFairPublisherId!;
      final BookFairStallEntity stall = widget.event.stalls.firstWhere(
        (BookFairStallEntity s) => s.id == stallId,
        orElse: () => BookFairStallEntity(
          id: stallId,
          name: 'Unknown Stall',
          stallNo: 'N/A',
          halls: const <String>[],
        ),
      );
      return PublisherStallPair(p, stall);
    }).toList();
    final Map<String, List<PublisherStallPair>> grouped = <String, List<PublisherStallPair>>{};
    for (final PublisherStallPair pair in pairs) {
      for (final String hall in pair.stall.halls) {
        grouped.putIfAbsent(hall, () => <PublisherStallPair>[]).add(pair);
      }
    }

    final List<String> sortedHalls = grouped.keys.toList()..sort();
    final Set<String> allStallIds = pairs.map((PublisherStallPair p) => p.stall.id).toSet();
    final int totalStalls = allStallIds.length;
    final int visitedCount = allStallIds.intersection(_visitedStalls).length;
    final double progress = totalStalls > 0 ? visitedCount / totalStalls : 0.0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('CIBF ${widget.event.year} Shopping Plan'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: purplePrimary,
        elevation: 0,
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.edit_road_rounded, size: 18),
            label: const Text('Edit Plan'),
            onPressed: widget.onEditMappings,
            style: TextButton.styleFrom(
              foregroundColor: purplePrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          BookFairProgressCard(
            visitedCount: visitedCount,
            totalStalls: totalStalls,
            progress: progress,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: sortedHalls.length,
              itemBuilder: (BuildContext context, int index) {
                final String hallId = sortedHalls[index];
                final List<PublisherStallPair> groupPairs = grouped[hallId]!;

                return BookFairHallGroupCard(
                  hallId: hallId,
                  groupPairs: groupPairs,
                  visitedStalls: _visitedStalls,
                  onToggleVisited: (String stallId) {
                    setState(() {
                      if (_visitedStalls.contains(stallId)) {
                        _visitedStalls.remove(stallId);
                      } else {
                        _visitedStalls.add(stallId);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
