import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/presentation/routes/route_constants.dart';
import '../../../../core/shared/presentation/routes/router_service.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../creator/domain/entities/creator_entity.dart';
import '../../../creator/presentation/providers/creator_provider.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../data/services/book_fair_sheets_service.dart';
import '../../domain/entities/book_fair_event_entity.dart';
import '../../domain/entities/book_fair_stall_entity.dart';
import '../providers/book_fair_event_provider.dart';
import '../providers/book_fair_sync_controller.dart';
import '../widgets/book_fair_hall_group_card.dart';
import '../widgets/book_fair_progress_card.dart';
import '../widgets/book_fair_sheet_qr_dialog.dart';
import '../widgets/book_fair_stall_selection_dialog.dart';
import '../widgets/book_fair_sync_dialog.dart';

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
          ref.read(goRouterProvider).goNamed(RouteConstants.bookFair);
          ref.read(lastConfiguredFairIdProvider.notifier).update(null);
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
              FaIcon(FontAwesomeIcons.circleExclamation, color: colorScheme.error, size: 48),
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
    final List<CreatorEntity> creators =
        ref.watch(creatorsStreamProvider).value ?? <CreatorEntity>[];

    final DateTime now = DateTime.now();
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
        ref.read(goRouterProvider).goNamed(RouteConstants.bookFair);
        ref.read(lastConfiguredFairIdProvider.notifier).update(null);
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
                  child: FaIcon(FontAwesomeIcons.compass, size: 64, color: purplePrimary),
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
                  icon: const FaIcon(FontAwesomeIcons.gear),
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

    // For progress calculation, check all publishers who had books in shopping list today
    final List<PublisherEntity> mappedForProgress = publishers.where((PublisherEntity p) {
      final String? bookFairPublisherId = p.bookFairPublisherId;
      final bool hasStallMapped =
          bookFairPublisherId != null &&
          bookFairPublisherId.startsWith('CIBF_${widget.event.year}_');
      final bool hasBooksInPlan = books.any((BookEntity b) =>
          b.publisherId == p.id &&
          (b.collectionStatus == CollectionStatus.shoppingList ||
           (b.collectionStatus == CollectionStatus.collected &&
            b.collectedDate != null &&
            now.difference(b.collectedDate!).inHours < 24)));
      return hasStallMapped && hasBooksInPlan;
    }).toList();

    final List<PublisherStallPair> progressPairs = mappedForProgress.map((PublisherEntity p) {
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

    final Set<String> allProgressStallIds = progressPairs.map((PublisherStallPair p) => p.stall.id).toSet();
    final int totalStalls = allProgressStallIds.length;

    // Calculate dynamically which stalls are completed (all mapped books are in collected state)
    final Set<String> completedStallIds = <String>{};
    for (final PublisherStallPair pair in progressPairs) {
      final List<BookEntity> publisherBooks = books
          .where((BookEntity b) =>
              b.publisherId == pair.publisher.id &&
              (b.collectionStatus == CollectionStatus.shoppingList ||
               (b.collectionStatus == CollectionStatus.collected &&
                b.collectedDate != null &&
                now.difference(b.collectedDate!).inHours < 24)))
          .toList();
      if (publisherBooks.isNotEmpty &&
          publisherBooks.every((BookEntity b) => b.collectionStatus == CollectionStatus.collected)) {
        completedStallIds.add(pair.stall.id);
      }
    }

    final int visitedCount = completedStallIds.length;
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
          // --- Sync / Share button -------------------------------------------
          // Builds the book list from the already-loaded books, exports to a
          // new Google Sheet, then opens the QR dialog on success.
          Builder(
            builder: (BuildContext ctx) {
              final BookFairSyncState syncState =
                  ref.watch(bookFairSyncControllerProvider);
              final bool isExporting =
                  syncState.status == BookFairSyncStatus.exporting;

              if (isExporting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              return PopupMenuButton<int>(
                icon: FaIcon(
                  FontAwesomeIcons.ellipsisVertical,
                  size: 20,
                  color: purplePrimary,
                ),
                onSelected: (int value) async {
                  if (value == 0) {
                    widget.onEditMappings();
                  } else if (value == 1 || value == 2) {
                    // Collect only shopping-list books with full entity
                    // context needed for the enriched sheet export (and sync).
                    final List<BookFairExportEntry> entries = books
                        .where(
                          (BookEntity b) =>
                              b.collectionStatus ==
                              CollectionStatus.shoppingList,
                        )
                        .map((BookEntity book) {
                      // Resolve author names from authorIds.
                      final List<String> authorNames = book.authorIds
                          .map(
                            (String id) => creators
                                .where((CreatorEntity a) => a.id == id)
                                .map((CreatorEntity a) => a.name)
                                .firstOrNull ?? '',
                          )
                          .where((String n) => n.isNotEmpty)
                          .toList();

                      // Resolve translator names from translatorIds.
                      final List<String> translatorNames =
                          book.translatorIds
                              .map(
                                (String id) => creators
                                    .where(
                                      (CreatorEntity t) => t.id == id,
                                    )
                                    .map((CreatorEntity t) => t.name)
                                    .firstOrNull ?? '',
                              )
                              .where((String n) => n.isNotEmpty)
                              .toList();

                      // Combine authors and translators into Creators
                      String creatorNames = '';
                      final String authorStr = authorNames.join(', ');
                      final String translatorStr = translatorNames.join(', ');
                      if (translatorStr.isNotEmpty) {
                        creatorNames = '$translatorStr ($authorStr)';
                      } else {
                        creatorNames = authorStr;
                      }

                      // Resolve publisher + stall info via publisherId.
                      final PublisherEntity? publisher = publishers
                          .where(
                            (PublisherEntity p) =>
                                p.id == book.publisherId,
                          )
                          .cast<PublisherEntity?>()
                          .firstOrNull;

                      BookFairStallEntity? stall;
                      if (publisher?.bookFairPublisherId != null) {
                        stall = widget.event.stalls
                            .where(
                              (BookFairStallEntity s) =>
                                  s.id ==
                                  publisher!.bookFairPublisherId,
                            )
                            .cast<BookFairStallEntity?>()
                            .firstOrNull;
                      }

                      return BookFairExportEntry(
                        book: book,
                        creators: creatorNames,
                        publisherName: publisher?.name ?? '',
                        halls: stall?.halls ?? <String>[],
                        stallNo: stall?.stallNo ?? '',
                        stallName: stall?.name ?? '',
                      );
                    }).toList();

                    // Sort the entries: Hall -> Stall -> Title
                    entries.sort((BookFairExportEntry a, BookFairExportEntry b) {
                      final String hallA = a.halls.isNotEmpty ? a.halls.first : '';
                      final String hallB = b.halls.isNotEmpty ? b.halls.first : '';
                      int cmp = hallA.compareTo(hallB);
                      if (cmp != 0) {
                        return cmp;
                      }

                      cmp = a.stallNo.compareTo(b.stallNo);
                      if (cmp != 0) {
                        return cmp;
                      }

                      return a.book.title.compareTo(b.book.title);
                    });

                    // Keep a plain BookEntity list for the pull dialog.
                    final List<BookEntity> allShoppingBooks = entries
                        .map((BookFairExportEntry e) => e.book)
                        .toList();

                    if (value == 1) {
                      // Show stall selection dialog
                      final List<BookFairExportEntry>? selectedEntries =
                          await BookFairStallSelectionDialog.show(
                        ctx,
                        entries,
                      );

                      // If user cancelled the dialog, abort export
                      if (selectedEntries == null || !ctx.mounted) {
                        return;
                      }

                      // Keep a plain BookEntity list for the QR dialog.
                      final List<BookEntity> selectedShoppingBooks =
                          selectedEntries
                              .map((BookFairExportEntry e) => e.book)
                              .toList();

                      // Reset any previous sync state before starting.
                      ref
                          .read(bookFairSyncControllerProvider.notifier)
                          .reset();

                      // Kick off export; controller updates its own state.
                      await ref
                          .read(bookFairSyncControllerProvider.notifier)
                          .exportAndShare(selectedEntries);

                      final BookFairSyncState result =
                          ref.read(bookFairSyncControllerProvider);

                      if (!ctx.mounted) {
                        return;
                      }

                      if (result.status == BookFairSyncStatus.done &&
                          result.sheetUrl != null) {
                        // Open the QR dialog on success.
                        await BookFairSheetQrDialog.show(
                          ctx,
                          selectedShoppingBooks,
                        );
                      } else if (result.status == BookFairSyncStatus.error) {
                        // Surface the error as a snack bar.
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(
                              result.error ??
                                  'Export failed. Please try again.',
                            ),
                            backgroundColor:
                                Theme.of(ctx).colorScheme.error,
                          ),
                        );
                      }
                    } else if (value == 2) {
                      // Sync - we sync all shopping list items, not filtered
                      ref.read(bookFairSyncControllerProvider.notifier).reset();
                      await BookFairSyncDialog.show(ctx, allShoppingBooks);
                    }
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                  PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                      children: <Widget>[
                        FaIcon(FontAwesomeIcons.road, size: 18, color: purplePrimary),
                        const SizedBox(width: 12),
                        const Text('Edit Plan'),
                      ],
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                      children: <Widget>[
                        FaIcon(FontAwesomeIcons.shareNodes, size: 18, color: purplePrimary),
                        const SizedBox(width: 12),
                        const Text('Share'),
                      ],
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Row(
                      children: <Widget>[
                        FaIcon(FontAwesomeIcons.arrowsRotate, size: 18, color: purplePrimary),
                        const SizedBox(width: 12),
                        const Text('Sync'),
                      ],
                    ),
                  ),
                ],
              );
            },
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
                  completedStallIds: completedStallIds,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
