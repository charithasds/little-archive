import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/user_profile_provider.dart';
import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/presentation/routes/router_service.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final Map<String, String?> _publisherStallMap = <String, String?>{};
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

    final AsyncValue<List<BookEntity>> booksAsync = ref.watch(booksStreamProvider);
    final AsyncValue<List<PublisherEntity>> publishersAsync = ref.watch(publishersStreamProvider);
    final AsyncValue<BookFairEventEntity> bookFairEventAsync = ref.watch(bookFairEventProvider);
    final AsyncValue<UserEntity?> userAsync = ref.watch(userProfileProvider);

    if (bookFairEventAsync.isLoading ||
        publishersAsync.isLoading ||
        booksAsync.isLoading ||
        userAsync.isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('CIBF Setup'),
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          centerTitle: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (bookFairEventAsync.hasError ||
        publishersAsync.hasError ||
        booksAsync.hasError ||
        userAsync.hasError) {
      final Object error =
          bookFairEventAsync.error ?? publishersAsync.error ?? booksAsync.error ?? userAsync.error!;

      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          centerTitle: false,
        ),
        body: Center(
          child: Text('Error: $error', style: TextStyle(color: colorScheme.error)),
        ),
      );
    }

    final List<BookEntity> books = booksAsync.value!;
    final List<PublisherEntity> publishers = publishersAsync.value!;
    final BookFairEventEntity bookFairEvent = bookFairEventAsync.value!;
    final UserEntity? user = userAsync.value;
    final String? lastConfiguredFairId = user?.lastConfiguredFairId;

    final Set<String> allPublisherIdsInShoppingList = books
        .where(
          (BookEntity b) =>
              b.collectionStatus == CollectionStatus.shoppingList && b.publisherId != null,
        )
        .map((BookEntity b) => b.publisherId!)
        .toSet();
    final List<PublisherEntity> unmappedPublisherIdsInShoppingList = publishers
        .where(
          (PublisherEntity p) =>
              allPublisherIdsInShoppingList.contains(p.id) &&
              p.bookFairPublisherId != 'none' &&
              (p.bookFairPublisherId == null ||
                  !p.bookFairPublisherId!.startsWith('CIBF_${bookFairEvent.year}_')),
        )
        .toList();

    if (unmappedPublisherIdsInShoppingList.isEmpty && lastConfiguredFairId == bookFairEvent.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.goNamed(RouteConstants.shoppingPlan);
        }
      });

      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Redirecting to Shopping Plan...'),
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          centerTitle: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    for (final PublisherEntity publisher in publishers) {
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

    final List<PublisherEntity> filteredPublishers = publishers.where((PublisherEntity publisher) {
      if (!allPublisherIdsInShoppingList.contains(publisher.id)) {
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

    filteredPublishers.sort((PublisherEntity p1, PublisherEntity p2) {
      final bool p1AlreadyConfigured =
          p1.bookFairPublisherId == 'none' ||
          (p1.bookFairPublisherId != null &&
              p1.bookFairPublisherId!.startsWith('CIBF_${bookFairEvent.year}_'));
      final bool p2AlreadyConfigured =
          p2.bookFairPublisherId == 'none' ||
          (p2.bookFairPublisherId != null &&
              p2.bookFairPublisherId!.startsWith('CIBF_${bookFairEvent.year}_'));

      final bool p1InShoppingList = allPublisherIdsInShoppingList.contains(p1.id);
      final bool p2InShoppingList = allPublisherIdsInShoppingList.contains(p2.id);

      final bool p1ToBeConfigured = !p1AlreadyConfigured && p1InShoppingList;
      final bool p2ToBeConfigured = !p2AlreadyConfigured && p2InShoppingList;

      if (p1ToBeConfigured && !p2ToBeConfigured) {
        return -1;
      }

      if (!p1ToBeConfigured && p2ToBeConfigured) {
        return 1;
      }

      return p1.name.compareTo(p2.name);
    });

    final int alreadyMappedCount = filteredPublishers
        .where(
          (PublisherEntity p) =>
              p.bookFairPublisherId != null &&
              p.bookFairPublisherId!.startsWith('CIBF_${bookFairEvent.year}_'),
        )
        .length;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('CIBF ${bookFairEvent.year} Setup'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search publishers',
              leading: const FaIcon(FontAwesomeIcons.magnifyingGlass),
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
                      final PublisherEntity publisher = filteredPublishers[index];
                      final String? publisherStallId = _publisherStallMap[publisher.id];
                      final BookFairStallEntity? selectedStall =
                          publisherStallId != null && publisherStallId != 'none'
                          ? bookFairEvent.stalls.firstWhere(
                              (BookFairStallEntity bfs) => bfs.id == publisherStallId,
                              orElse: () => BookFairStallEntity(
                                id: publisherStallId,
                                name: 'Unknown Stall',
                                stallNo: 'N/A',
                                halls: const <String>[],
                              ),
                            )
                          : null;

                      return PublisherStallMappingCard(
                        publisher: publisher,
                        selectedStallId: publisherStallId,
                        selectedStall: selectedStall,
                        onTapStall: () =>
                            _showSearchStallsSheet(context, publisher, bookFairEvent.stalls),
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
                      '$alreadyMappedCount of ${filteredPublishers.length} Mapped',
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
                        : const FaIcon(FontAwesomeIcons.circleCheck),
                    label: Text(
                      _isSaving ? 'Saving Mapped Publishers...' : 'Confirm & Go to Shopping Plan',
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
                                            bookFairPublisherId: Nullable<String?>(activeStallId),
                                          ),
                                        ),
                                  );
                                }
                              }

                              if (editFutures.isNotEmpty) {
                                await Future.wait(editFutures);
                              }

                              if (context.mounted) {
                                context.goNamed(RouteConstants.shoppingPlan);
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
                  icon: const FaIcon(FontAwesomeIcons.xmark),
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
              leading: const FaIcon(FontAwesomeIcons.magnifyingGlass),
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
                      child: FaIcon(FontAwesomeIcons.linkSlash, color: cs.error, size: 20),
                    ),
                    title: Text(
                      'Select None',
                      style: TextStyle(color: cs.error, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Do not map this publisher to any stall'),
                    trailing: FaIcon(FontAwesomeIcons.chevronRight, color: cs.error),
                    onTap: () => widget.onSelect('none'),
                  );
                }

                if (_filteredBookFairStall.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FaIcon(
                          FontAwesomeIcons.magnifyingGlassMinus,
                          size: 48,
                          color: cs.onSurfaceVariant,
                        ),
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
                    child: FaIcon(FontAwesomeIcons.store, color: purplePrimary, size: 20),
                  ),
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Hall ${s.halls.join(', ')} • Stall ${s.stallNo}'),
                  trailing: const FaIcon(FontAwesomeIcons.chevronRight),
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
