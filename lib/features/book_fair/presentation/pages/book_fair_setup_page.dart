import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/presentation/providers/user_profile_provider.dart';
import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../publisher/data/repositories/publisher_repository_impl.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../domain/entities/book_fair_event_entity.dart';
import '../../domain/entities/book_fair_stall_entity.dart';
import '../../domain/usecases/match_publishers_usecase.dart';
import '../providers/book_fair_event_provider.dart';
import '../widgets/publisher_stall_mapping_card.dart';

class BookFairSetupPage extends ConsumerStatefulWidget {
  const BookFairSetupPage({super.key});

  @override
  ConsumerState<BookFairSetupPage> createState() => _BookFairSetupPageState();
}

class _BookFairSetupPageState extends ConsumerState<BookFairSetupPage> {
  final Map<String, String?> _publisherStallMap = <String, String?>{};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color purplePrimary = isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2);
    final Color onPurplePrimary = isDark ? const Color(0xFF311B92) : Colors.white;
    final AsyncValue<BookFairEventEntity> eventAsync = ref.watch(bookFairEventProvider);
    final List<PublisherEntity> allPublishers =
        ref.watch(publishersStreamProvider).value ?? <PublisherEntity>[];
    final List<BookEntity> books = ref.watch(booksStreamProvider).value ?? <BookEntity>[];
    final Set<String> publisherIdsInShoppingList = books
        .where(
          (BookEntity b) =>
              b.collectionStatus == CollectionStatus.shoppingList && b.publisherId != null,
        )
        .map((BookEntity b) => b.publisherId!)
        .toSet();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          eventAsync.value?.year != null ? 'CIBF ${eventAsync.value!.year} Setup' : 'CIBF Setup',
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      body: eventAsync.when(
        data: (BookFairEventEntity bookFairEvent) {
          for (final PublisherEntity publisher in allPublishers) {
            if (!_publisherStallMap.containsKey(publisher.id)) {
              if (publisher.bookFairPublisherId != null) {
                _publisherStallMap[publisher.id] = publisher.bookFairPublisherId;
              } else {
                final BookFairStallEntity? bookFairStall = ref
                    .read(matchPublishersUseCaseProvider)
                    .findBestSuggestion(publisher, bookFairEvent.stalls);

                _publisherStallMap[publisher.id] = bookFairStall?.id;
              }
            }
          }

          final List<PublisherEntity> filteredPublishers = allPublishers.where((
            PublisherEntity publisher,
          ) {
            if (!publisherIdsInShoppingList.contains(publisher.id)) {
              return false;
            }

            final String query = _searchQuery.toLowerCase().trim();

            if (query.isEmpty) {
              return true;
            }

            final bool nameMatches = publisher.name.toLowerCase().contains(query);
            final bool otherNameMatches =
                publisher.otherName != null && publisher.otherName!.toLowerCase().contains(query);

            return nameMatches || otherNameMatches;
          }).toList();

          filteredPublishers.sort((PublisherEntity a, PublisherEntity b) {
            final bool aConfigured =
                a.bookFairPublisherId == 'none' ||
                (a.bookFairPublisherId != null &&
                 a.bookFairPublisherId!.startsWith('CIBF_${bookFairEvent.year}_'));
            final bool bConfigured =
                b.bookFairPublisherId == 'none' ||
                (b.bookFairPublisherId != null &&
                 b.bookFairPublisherId!.startsWith('CIBF_${bookFairEvent.year}_'));

            final bool aInShopping = publisherIdsInShoppingList.contains(a.id);
            final bool bInShopping = publisherIdsInShoppingList.contains(b.id);

            final bool aUrgent = !aConfigured && aInShopping;
            final bool bUrgent = !bConfigured && bInShopping;

            if (aUrgent && !bUrgent) {
              return -1;
            }

            if (!aUrgent && bUrgent) {
              return 1;
            }

            final bool aUnmapped = !aConfigured;
            final bool bUnmapped = !bConfigured;

            if (aUnmapped && !bUnmapped) {
              return -1;
            }

            if (!aUnmapped && bUnmapped) {
              return 1;
            }

            return a.name.compareTo(b.name);
          });

          final int mappedCount = filteredPublishers
              .where((PublisherEntity p) {
                final String? mappingId = _publisherStallMap[p.id];
                return mappingId != null &&
                    mappingId != 'none' &&
                    mappingId.startsWith('CIBF_${bookFairEvent.year}_');
              })
              .length;

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search publishers',
                  leading: const Icon(Icons.search_rounded),
                  elevation: const WidgetStatePropertyAll<double>(0),
                  backgroundColor: WidgetStatePropertyAll<Color>(colorScheme.surfaceContainerHigh),
                  shape: WidgetStatePropertyAll<OutlinedBorder>(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              Expanded(
                child: filteredPublishers.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No publishers yet. Add publishers to start mapping'
                              : 'No publishers match your search.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredPublishers.length,
                        itemBuilder: (BuildContext context, int index) {
                          final PublisherEntity pub = filteredPublishers[index];
                          final String? selectedStallId = _publisherStallMap[pub.id];
                          final BookFairStallEntity? selectedStall =
                              selectedStallId != null && selectedStallId != 'none'
                              ? bookFairEvent.stalls.firstWhere(
                                  (BookFairStallEntity s) => s.id == selectedStallId,
                                  orElse: () => BookFairStallEntity(
                                    id: selectedStallId,
                                    name: 'Unknown Stall',
                                    stallNo: 'N/A',
                                    halls: const <String>[],
                                  ),
                                )
                              : null;

                          return PublisherStallMappingCard(
                            publisher: pub,
                            selectedStallId: selectedStallId,
                            selectedStall: selectedStall,
                            onTapStall: () =>
                                _showSearchStallsSheet(context, pub, bookFairEvent.stalls),
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '$mappedCount of ${filteredPublishers.length} Mapped',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purplePrimary,
                          foregroundColor: onPurplePrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.check_circle_rounded),
                        label: Text(
                          _isSaving
                              ? 'Saving Mapped Publishers...'
                              : 'Confirm & Go to Shopping Plan',
                        ),
                        onPressed: _isSaving
                            ? null
                            : () async {
                                setState(() {
                                  _isSaving = true;
                                });

                                try {
                                  await ref
                                      .read(userProfileControllerProvider.notifier)
                                      .updateLastConfiguredFairId(bookFairEvent.id);

                                  final List<Future<void>> editFutures = <Future<void>>[];

                                  for (final PublisherEntity publisher in filteredPublishers) {
                                    final String? activeStallId = _publisherStallMap[publisher.id];

                                    if (publisher.bookFairPublisherId != activeStallId) {
                                      editFutures.add(
                                        ref
                                            .read(publisherRepositoryProvider)
                                            .editPublisher(
                                              publisher.copyWith(
                                                bookFairPublisherId: Nullable<String?>(
                                                  activeStallId,
                                                ),
                                              ),
                                            ),
                                      );
                                    }
                                  }

                                  if (editFutures.isNotEmpty) {
                                    await Future.wait(editFutures);
                                  }

                                  if (context.mounted) {
                                    context.go('/shopping-plan');
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to save plan: $e'),
                                        backgroundColor: colorScheme.error,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isSaving = false;
                                    });
                                  }
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace? s) => Center(child: Text('Error loading events: $e')),
      ),
    );
  }

  void _showSearchStallsSheet(
    BuildContext context,
    PublisherEntity publisher,
    List<BookFairStallEntity> stalls,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => _SearchStallsSheet(
        publisher: publisher,
        allStalls: stalls,
        onSelect: (String? stallId) {
          setState(() {
            _publisherStallMap[publisher.id] = stallId;
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SearchStallsSheet extends ConsumerStatefulWidget {
  const _SearchStallsSheet({
    required this.publisher,
    required this.allStalls,
    required this.onSelect,
  });

  final PublisherEntity publisher;
  final List<BookFairStallEntity> allStalls;
  final ValueChanged<String?> onSelect;

  @override
  ConsumerState<_SearchStallsSheet> createState() => _SearchStallsSheetState();
}

class _SearchStallsSheetState extends ConsumerState<_SearchStallsSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<BookFairStallEntity> _filteredBookFairStall = <BookFairStallEntity>[];
  String? _selectedHall;

  @override
  void initState() {
    super.initState();
    _filteredBookFairStall = widget.allStalls;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterStalls();
  }

  void _filterStalls() {
    final String query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredBookFairStall = widget.allStalls.where((BookFairStallEntity s) {
        final bool matchesQuery =
            query.isEmpty ||
            s.name.toLowerCase().contains(query) ||
            s.stallNo.toLowerCase().contains(query);
        final bool matchesHall = _selectedHall == null || s.halls.contains(_selectedHall);

        return matchesQuery && matchesHall;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme cs = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color purpleContainer = isDark
        ? const Color(0xFF4A148C).withValues(alpha: 0.18)
        : const Color(0xFFE1BEE7).withValues(alpha: 0.35);
    final Color purplePrimary = isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2);
    final Set<String> halls = widget.allStalls.expand((BookFairStallEntity s) => s.halls).toSet();
    final List<String> sortedHalls = halls.toList()..sort();

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
      padding: EdgeInsets.only(bottom: keyboardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Map "${widget.publisher.name}" to CIBF Directory',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search stall or publisher name...',
              leading: const Icon(Icons.search_rounded),
              elevation: const WidgetStatePropertyAll<double>(0),
              backgroundColor: WidgetStatePropertyAll<Color>(cs.surfaceContainerHigh),
              shape: WidgetStatePropertyAll<OutlinedBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: sortedHalls.length + 1,
              itemBuilder: (BuildContext context, int index) {
                final bool isAll = index == 0;
                final String? hallName = isAll ? null : sortedHalls[index - 1];
                final bool isSelected = _selectedHall == hallName;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(isAll ? 'All Halls' : 'Hall $hallName'),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedHall = selected ? hallName : null;
                        _filterStalls();
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredBookFairStall.isEmpty ? 2 : _filteredBookFairStall.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.errorContainer.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.link_off_rounded, color: cs.error, size: 20),
                    ),
                    title: Text(
                      'Select None',
                      style: TextStyle(color: cs.error, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Do not map this publisher to any stall'),
                    trailing: Icon(Icons.chevron_right_rounded, color: cs.error),
                    onTap: () => widget.onSelect('none'),
                  );
                }

                if (_filteredBookFairStall.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.search_off_rounded, size: 48, color: cs.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text(
                          'No stalls match your search.',
                          style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                }

                final BookFairStallEntity s = _filteredBookFairStall[index - 1];

                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: purpleContainer.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.storefront_rounded, color: purplePrimary, size: 20),
                  ),
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Hall ${s.halls.join(', ')} • Stall ${s.stallNo}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => widget.onSelect(s.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
