import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/entity.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/presentation/utils/validators.dart';
import '../../../../core/shared/presentation/widgets/custom_icons.dart';
import '../../../../core/shared/presentation/widgets/search_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../creator/domain/entities/creator_entity.dart';
import '../../../creator/presentation/providers/creator_provider.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../../reader/domain/entities/reader_entity.dart';
import '../../../reader/presentation/providers/reader_provider.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../work/domain/entities/work_entity.dart';
import '../../../work/presentation/providers/work_provider.dart';
import '../../domain/entities/book_entity.dart';
import '../providers/book_provider.dart';

class BookDataQualityManagePage extends ConsumerStatefulWidget {
  const BookDataQualityManagePage({super.key});

  @override
  ConsumerState<BookDataQualityManagePage> createState() => _BookDataQualityManagePageState();
}

class _BookDataQualityManagePageState extends ConsumerState<BookDataQualityManagePage>
    with SingleTickerProviderStateMixin {
  static const List<Entity> _entities = Entity.values;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _entities.length, vsync: this);
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
    final List<BookEntity>? books = ref.watch(booksStreamProvider).value;
    final List<WorkEntity>? works = ref.watch(worksStreamProvider).value;
    final List<CreatorEntity>? creators = ref.watch(creatorsStreamProvider).value;
    final List<PublisherEntity>? publishers = ref.watch(publishersStreamProvider).value;
    final List<ReaderEntity>? readers = ref.watch(readersStreamProvider).value;
    final List<SequenceEntity>? sequences = ref.watch(sequencesStreamProvider).value;
    final List<SequenceVolumeEntity>? sequenceVolumes = ref
        .watch(allSequenceVolumesStreamProvider)
        .value;

    final bool isDark = theme.brightness == Brightness.dark;
    final Color redText = isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828);
    final Color redBadgeBg = isDark ? const Color(0xFFC62828) : const Color(0xFFFFCDD2);
    final Color redOnBadgeBg = isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828);

    int? getCountFor(Entity entity) {
      switch (entity) {
        case Entity.book:
          return books?.where((BookEntity b) => _missingForBook(b).isNotEmpty).length;
        case Entity.work:
          return works?.where((WorkEntity w) => _missingForWork(w).isNotEmpty).length;
        case Entity.creator:
          return creators?.where((CreatorEntity c) => _missingForCreator(c).isNotEmpty).length;
        case Entity.publisher:
          return publishers
              ?.where((PublisherEntity p) => _missingForPublisher(p).isNotEmpty)
              .length;
        case Entity.reader:
          return readers?.where((ReaderEntity r) => _missingForReader(r).isNotEmpty).length;
        case Entity.sequence:
          return sequences?.where((SequenceEntity s) => _missingForSequence(s).isNotEmpty).length;
        case Entity.sequenceVolume:
          return sequenceVolumes
              ?.where((SequenceVolumeEntity sv) => _missingForSequenceVolume(sv).isNotEmpty)
              .length;
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: redText,
        title: const Text('Data Quality'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: redText,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: redText,
          dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.4),
          tabs: _entities.map((Entity entity) {
            final int? count = getCountFor(entity);

            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildAppIcon(entity.icon, size: 16)!,
                  const SizedBox(width: 6),
                  Text(entity.clientPluralValue),
                  if (count == null)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(redText.withValues(alpha: 0.5)),
                        ),
                      ),
                    )
                  else if (count > 0) ...<Widget>[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: redBadgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: redOnBadgeBg,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _entities.map((Entity entity) => _EntityQualityTab(entity: entity)).toList(),
      ),
    );
  }
}

class _QualityListView<T> extends ConsumerWidget {
  const _QualityListView({
    required this.items,
    required this.tileBuilder,
    this.emptyIcon = FontAwesomeIcons.circleCheck,
    this.emptyLabel = 'All data complete',
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) tileBuilder;
  final dynamic emptyIcon;
  final String emptyLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      final ThemeData theme = ref.watch(activeThemeDataProvider);
      final ColorScheme colorScheme = theme.colorScheme;

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildAppIcon(
              emptyIcon,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            )!,
            const SizedBox(height: 16),
            Text(
              emptyLabel,
              style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) => tileBuilder(context, items[index]),
    );
  }
}

class _QualityTile extends ConsumerWidget {
  const _QualityTile({
    required this.name,
    required this.missingChips,
    required this.onEdit,
    required this.redText,
  });

  final String name;
  final List<String> missingChips;
  final VoidCallback onEdit;
  final Color redText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color cardBg = isDark
        ? const Color(0xFFB71C1C).withValues(alpha: 0.12)
        : const Color(0xFFFFCDD2).withValues(alpha: 0.18);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: redText.withValues(alpha: 0.3)),
      ),
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: missingChips
                        .map(
                          (String chip) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: redText.withValues(alpha: 0.1),
                              border: Border.all(color: redText.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                FaIcon(
                                  FontAwesomeIcons.circleExclamation,
                                  size: 16,
                                  color: redText,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  chip,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: redText,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              icon: const FaIcon(FontAwesomeIcons.penToSquare),
              tooltip: 'Edit',
              onPressed: onEdit,
              style: IconButton.styleFrom(
                foregroundColor: redText,
                side: BorderSide(color: redText.withValues(alpha: 0.3)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> _missingForBook(BookEntity b) {
  final List<String> missing = <String>[];

  final bool isNotCollected =
      b.collectionStatus == CollectionStatus.announced ||
      b.collectionStatus == CollectionStatus.onTheWay ||
      b.collectionStatus == CollectionStatus.outOfPrint ||
      b.collectionStatus == CollectionStatus.shoppingList;

  if (!b.toBeTranslated && !isNotCollected && b.cover == null) {
    missing.add('Cover');
  }

  if (b.language == null) {
    missing.add('Language');
  }

  if (b.compilationType == CompilationType.single && b.genre == null) {
    missing.add('Genre');
  }

  if (!b.toBeTranslated &&
      !isNotCollected &&
      !b.notForSale &&
      (b.isbn == null || !Validators.isValidIsbn13(b.isbn!))) {
    missing.add('ISBN');
  }

  if (!b.toBeTranslated && !isNotCollected && !b.notForSale && b.publishedDate == null) {
    missing.add('Published Date');
  }

  if (!b.toBeTranslated && !isNotCollected && b.noOfPages == null) {
    missing.add('Number of Pages');
  }

  if (b.compilationType == CompilationType.single &&
      b.isTranslation &&
      (b.originalTitle == null || b.originalTitle!.trim().isEmpty)) {
    missing.add('Original Title');
  }

  if (b.isTranslation && b.originalLanguage == null) {
    missing.add('Original Language');
  }

  if (!b.toBeTranslated &&
      ((b.collectionStatus == CollectionStatus.collected ||
              b.collectionStatus == CollectionStatus.lended) &&
          b.collectedDate == null)) {
    missing.add('Collected Date');
  }

  if (!b.toBeTranslated &&
      (b.collectionStatus == CollectionStatus.lended && b.lendedDate == null)) {
    missing.add('Lended Date');
  }

  if (!b.toBeTranslated && (b.collectionStatus == CollectionStatus.lended && b.dueDate == null)) {
    missing.add('Due Date');
  }

  if (!b.toBeTranslated && (b.readingStatus == ReadingStatus.paused && b.pausedPage == null)) {
    missing.add('Paused Page');
  }

  if (!b.toBeTranslated &&
      (b.readingStatus == ReadingStatus.completed && b.completedDate == null)) {
    missing.add('Completed Date');
  }

  if (b.compilationType == CompilationType.single && b.authorIds.isEmpty) {
    missing.add('Authors');
  }

  if (!b.toBeTranslated && b.isTranslation && b.translatorIds.isEmpty) {
    missing.add('Translators');
  }

  if (!b.toBeTranslated &&
      !b.notForSale &&
      b.collectionStatus != CollectionStatus.outOfPrint &&
      b.collectionStatus != CollectionStatus.announced &&
      b.publisherId == null) {
    missing.add('Publisher');
  }

  if (!b.toBeTranslated && (b.collectionStatus == CollectionStatus.lended && b.readerId == null)) {
    missing.add('Reader');
  }

  if (b.compilationType == CompilationType.single && !b.notForSale && b.sequenceVolumeIds.isEmpty) {
    missing.add('Sequences');
  }

  return missing;
}

List<String> _missingForWork(WorkEntity w) {
  final List<String> missing = <String>[];

  if (w.language == null) {
    missing.add('Language');
  }

  if (w.genre == null) {
    missing.add('Genre');
  }

  if (w.originalTitle == null || w.originalTitle!.trim().isEmpty) {
    missing.add('Original Title');
  }

  if (w.originalLanguage == null) {
    missing.add('Original Language');
  }

  if (w.authorIds.isEmpty) {
    missing.add('Authors');
  }

  if (!w.toBeTranslated && w.isTranslation && w.translatorIds.isEmpty) {
    missing.add('Translators');
  }

  if (w.sequenceVolumeIds.isEmpty) {
    missing.add('Sequences');
  }

  if (w.bookId == null) {
    missing.add('Book');
  }

  return missing;
}

List<String> _missingForCreator(CreatorEntity c) {
  final List<String> missing = <String>[];

  if (c.image == null) {
    missing.add('Image');
  }

  if (c.otherName == null || c.otherName!.trim().isEmpty) {
    missing.add('Other Name');
  }

  if (c.website == null || c.website!.trim().isEmpty) {
    missing.add('Website');
  }

  if (c.facebook == null || c.facebook!.trim().isEmpty) {
    missing.add('Facebook');
  }

  if (c.authoredBookIds.isEmpty &&
      c.authoredWorkIds.isEmpty &&
      c.translatedBookIds.isEmpty &&
      c.translatedWorkIds.isEmpty) {
    missing.add('Creations');
  }

  return missing;
}

List<String> _missingForPublisher(PublisherEntity p) {
  final List<String> missing = <String>[];

  if (!p.isSelfPublisher && p.logo == null) {
    missing.add('Logo');
  }

  if (p.otherName == null || p.otherName!.trim().isEmpty) {
    missing.add('Other Name');
  }

  if (!p.isSelfPublisher && (p.website == null || p.website!.trim().isEmpty)) {
    missing.add('Website');
  }

  if (!p.isSelfPublisher && (p.email == null || p.email!.trim().isEmpty)) {
    missing.add('Email');
  }

  if (!p.isSelfPublisher && (p.facebook == null || p.facebook!.trim().isEmpty)) {
    missing.add('Facebook');
  }

  if (!p.isSelfPublisher && (p.phoneNumber == null || p.phoneNumber!.trim().isEmpty)) {
    missing.add('Phone Number');
  }

  if (p.bookIds.isEmpty) {
    missing.add('Books');
  }

  return missing;
}

List<String> _missingForReader(ReaderEntity r) {
  final List<String> missing = <String>[];

  if (r.image == null) {
    missing.add('Image');
  }

  if (r.otherName == null || r.otherName!.trim().isEmpty) {
    missing.add('Other Name');
  }

  if (r.email == null || r.email!.trim().isEmpty) {
    missing.add('Email');
  }

  if (r.phoneNumber == null || r.phoneNumber!.trim().isEmpty) {
    missing.add('Phone Number');
  }

  if (r.facebook == null || r.facebook!.trim().isEmpty) {
    missing.add('Facebook');
  }

  if (r.bookIds.isEmpty) {
    missing.add('Books');
  }

  return missing;
}

List<String> _missingForSequence(SequenceEntity s) {
  final List<String> missing = <String>[];

  if (s.sequenceVolumeIds.isEmpty) {
    missing.add('Volumes');
  }

  return missing;
}

List<String> _missingForSequenceVolume(SequenceVolumeEntity sv) {
  final List<String> missing = <String>[];

  if (sv.bookId == null && sv.workId == null) {
    missing.add('Creation');
  }

  return missing;
}

class _EntityQualityTab extends ConsumerStatefulWidget {
  const _EntityQualityTab({required this.entity});

  final Entity entity;

  @override
  ConsumerState<_EntityQualityTab> createState() => _EntityQualityTabState();
}

class _EntityQualityTabState extends ConsumerState<_EntityQualityTab> {
  String _searchQuery = '';
  final Set<String> _selectedFilterChips = <String>{};

  List<String> _getMissingForEntityItem(Object item) {
    if (item is BookEntity) {
      return _missingForBook(item);
    }
    if (item is WorkEntity) {
      return _missingForWork(item);
    }
    if (item is CreatorEntity) {
      return _missingForCreator(item);
    }
    if (item is PublisherEntity) {
      return _missingForPublisher(item);
    }
    if (item is ReaderEntity) {
      return _missingForReader(item);
    }
    if (item is SequenceEntity) {
      return _missingForSequence(item);
    }
    if (item is SequenceVolumeEntity) {
      return _missingForSequenceVolume(item);
    }
    return <String>[];
  }

  List<Object>? _getItemsForEntity(Entity entity, WidgetRef ref) {
    switch (entity) {
      case Entity.book:
        return ref.watch(booksStreamProvider).value;
      case Entity.work:
        return ref.watch(worksStreamProvider).value;
      case Entity.creator:
        return ref.watch(creatorsStreamProvider).value;
      case Entity.publisher:
        return ref.watch(publishersStreamProvider).value;
      case Entity.reader:
        return ref.watch(readersStreamProvider).value;
      case Entity.sequence:
        return ref.watch(sequencesStreamProvider).value;
      case Entity.sequenceVolume:
        return ref.watch(allSequenceVolumesStreamProvider).value;
    }
  }

  String _getItemName(Object item) {
    if (item is BookEntity) {
      return item.title;
    }
    if (item is WorkEntity) {
      return item.title;
    }
    if (item is CreatorEntity) {
      return item.name;
    }
    if (item is PublisherEntity) {
      return item.name;
    }
    if (item is ReaderEntity) {
      return item.name;
    }
    if (item is SequenceEntity) {
      return item.name;
    }
    if (item is SequenceVolumeEntity) {
      return item.volume;
    }
    return '';
  }

  String _getEditRoute(Object item) {
    if (item is BookEntity) {
      return '/books/upsert';
    }
    if (item is WorkEntity) {
      return '/works/upsert';
    }
    if (item is CreatorEntity) {
      return '/creators/upsert';
    }
    if (item is PublisherEntity) {
      return '/publishers/upsert';
    }
    if (item is ReaderEntity) {
      return '/readers/upsert';
    }
    if (item is SequenceEntity) {
      return '/sequences/upsert';
    }
    if (item is SequenceVolumeEntity) {
      return '/sequence_volumes/upsert';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color redText = isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828);

    final List<Object>? rawItems = _getItemsForEntity(widget.entity, ref);
    if (rawItems == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<Object> incomplete = rawItems
        .where((Object item) => _getMissingForEntityItem(item).isNotEmpty)
        .toList();

    if (incomplete.isEmpty) {
      return _QualityListView<Object>(
        items: incomplete,
        emptyLabel: 'All ${widget.entity.clientPluralValue.toLowerCase()} have complete data',
        tileBuilder: (BuildContext context, Object item) => const SizedBox.shrink(),
      );
    }

    final Map<String, int> chipCounts = <String, int>{};
    for (final Object item in incomplete) {
      for (final String chip in _getMissingForEntityItem(item)) {
        chipCounts[chip] = (chipCounts[chip] ?? 0) + 1;
      }
    }

    // Automatically remove selected chips that are no longer missing in any items
    _selectedFilterChips.removeWhere((String chip) => !chipCounts.containsKey(chip));

    final List<Object> sortedAndFiltered = incomplete.where((Object item) {
      final String name = _getItemName(item);
      final bool matchesSearch =
          _searchQuery.isEmpty || name.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) {
        return false;
      }
      if (_selectedFilterChips.isEmpty) {
        return true;
      }
      final List<String> missing = _getMissingForEntityItem(item);
      return _selectedFilterChips.every((String chip) => missing.contains(chip));
    }).toList()
      ..sort(
        (Object a, Object b) =>
            _getItemName(a).toLowerCase().compareTo(_getItemName(b).toLowerCase()),
      );

    return _buildLayout<Object>(
      allIncompleteItems: incomplete,
      items: sortedAndFiltered,
      chipCounts: chipCounts,
      emptyLabel: 'All ${widget.entity.clientPluralValue.toLowerCase()} have complete data',
      tileBuilder: (BuildContext context, Object item) => _QualityTile(
        name: _getItemName(item),
        missingChips: _getMissingForEntityItem(item),
        onEdit: () => context.push(_getEditRoute(item), extra: item),
        redText: redText,
      ),
    );
  }

  Widget _buildLayout<T>({
    required List<T> allIncompleteItems,
    required List<T> items,
    required Map<String, int> chipCounts,
    required Widget Function(BuildContext context, T item) tileBuilder,
    required String emptyLabel,
  }) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color redText = isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828);

    final List<String> sortedChips = chipCounts.keys.toList()..sort();

    return Column(
      children: <Widget>[
        SearchField(
          onChanged: (String val) {
            setState(() {
              _searchQuery = val;
            });
          },
        ),
        if (sortedChips.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: sortedChips.map((String chip) {
                final bool isSelected = _selectedFilterChips.contains(chip);
                final int count = chipCounts[chip] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(chip),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? redText.withValues(alpha: 0.2)
                                : colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isSelected ? redText : colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedFilterChips.add(chip);
                        } else {
                          _selectedFilterChips.remove(chip);
                        }
                      });
                    },
                    selectedColor: redText.withValues(alpha: 0.2),
                    checkmarkColor: redText,
                    labelStyle: TextStyle(
                      color: isSelected ? redText : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        if (items.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'No results match your search or filter.',
                style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
          )
        else
          Expanded(
            child: _QualityListView<T>(
              items: items,
              emptyLabel: emptyLabel,
              tileBuilder: tileBuilder,
            ),
          ),
      ],
    );
  }
}
