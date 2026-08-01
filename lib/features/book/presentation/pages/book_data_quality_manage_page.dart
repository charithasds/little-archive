import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/entity.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
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
        case Entity.duplicateCreator:
          return creators != null ? _getDuplicateCreators(creators).length : null;
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
            buildAppIcon(emptyIcon, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4))!,
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
                                FaIcon(FontAwesomeIcons.circleExclamation, size: 16, color: redText),
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

  if (!b.toBeTranslated && b.cover == null) {
    missing.add('Cover');
  }

  if (b.language == null) {
    missing.add('Language');
  }

  if (b.genre == null) {
    missing.add('Genre');
  }

  if (!b.toBeTranslated && (b.isbn == null || b.isbn!.trim().isEmpty)) {
    missing.add('ISBN');
  }

  if (!b.toBeTranslated && b.publishedDate == null) {
    missing.add('Published Date');
  }

  if (!b.toBeTranslated && b.noOfPages == null) {
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

  if (b.authorIds.isEmpty) {
    missing.add('Authors');
  }

  if (!b.toBeTranslated && b.isTranslation && b.translatorIds.isEmpty) {
    missing.add('Translators');
  }

  if (!b.toBeTranslated && b.publisherId == null) {
    missing.add('Publisher');
  }

  if (!b.toBeTranslated && (b.collectionStatus == CollectionStatus.lended && b.readerId == null)) {
    missing.add('Reader');
  }

  if (b.compilationType == CompilationType.single && b.sequenceVolumeIds.isEmpty) {
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

  if (c.authoredBookIds.isEmpty && c.authoredWorkIds.isEmpty && c.translatedBookIds.isEmpty && c.translatedWorkIds.isEmpty) {
    missing.add('Creations');
  }

  return missing;
}

List<CreatorEntity> _getDuplicateCreators(List<CreatorEntity> creators) {
  final Map<String, List<CreatorEntity>> nameMap = <String, List<CreatorEntity>>{};
  for (final CreatorEntity creator in creators) {
    nameMap.putIfAbsent(creator.name.toLowerCase().trim(), () => <CreatorEntity>[]).add(creator);
  }
  return nameMap.values.where((List<CreatorEntity> list) => list.length > 1).expand((List<CreatorEntity> e) => e).toList();
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color redText = isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828);

    switch (widget.entity) {
      case Entity.book:
        final List<BookEntity>? books = ref.watch(booksStreamProvider).value;

        if (books == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<BookEntity> incomplete = books
            .where((BookEntity b) => _missingForBook(b).isNotEmpty)
            .toList();

        if (incomplete.isEmpty) {
          return _QualityListView<BookEntity>(
            items: incomplete,
            emptyLabel: 'All books have complete data',
            tileBuilder: (BuildContext context, BookEntity book) => const SizedBox.shrink(),
          );
        }

        final List<BookEntity> sortedAndFiltered = incomplete
            .where((BookEntity b) {
              if (_searchQuery.isEmpty) {
                return true;
              }
              return b.title.toLowerCase().contains(_searchQuery.toLowerCase());
            })
            .toList()
          ..sort((BookEntity a, BookEntity b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

        return _buildLayout<BookEntity>(
          items: sortedAndFiltered,
          emptyLabel: 'All books have complete data',
          tileBuilder: (BuildContext context, BookEntity book) => _QualityTile(
            name: book.title,
            missingChips: _missingForBook(book),
            onEdit: () => context.push('/books/upsert', extra: book),
            redText: redText,
          ),
        );
      case Entity.work:
        final List<WorkEntity>? works = ref.watch(worksStreamProvider).value;

        if (works == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<WorkEntity> incomplete = works
            .where((WorkEntity w) => _missingForWork(w).isNotEmpty)
            .toList();

        if (incomplete.isEmpty) {
          return _QualityListView<WorkEntity>(
            items: incomplete,
            emptyLabel: 'All works have complete data',
            tileBuilder: (BuildContext context, WorkEntity work) => const SizedBox.shrink(),
          );
        }

        final List<WorkEntity> sortedAndFiltered = incomplete
            .where((WorkEntity w) {
              if (_searchQuery.isEmpty) {
                return true;
              }
              return w.title.toLowerCase().contains(_searchQuery.toLowerCase());
            })
            .toList()
          ..sort((WorkEntity a, WorkEntity b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

        return _buildLayout<WorkEntity>(
          items: sortedAndFiltered,
          emptyLabel: 'All works have complete data',
          tileBuilder: (BuildContext context, WorkEntity work) => _QualityTile(
            name: work.title,
            missingChips: _missingForWork(work),
            onEdit: () => context.push('/works/upsert', extra: work),
            redText: redText,
          ),
        );
      case Entity.creator:
        final List<CreatorEntity>? creators = ref.watch(creatorsStreamProvider).value;

        if (creators == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<CreatorEntity> incomplete = creators
            .where((CreatorEntity c) => _missingForCreator(c).isNotEmpty)
            .toList();

        if (incomplete.isEmpty) {
          return _QualityListView<CreatorEntity>(
            items: incomplete,
            emptyLabel: 'All creators have complete data',
            tileBuilder: (BuildContext context, CreatorEntity creator) => const SizedBox.shrink(),
          );
        }

        final List<CreatorEntity> sortedAndFiltered = incomplete
            .where((CreatorEntity c) {
              if (_searchQuery.isEmpty) {
                return true;
              }
              return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
            })
            .toList()
          ..sort((CreatorEntity a, CreatorEntity b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        return _buildLayout<CreatorEntity>(
          items: sortedAndFiltered,
          emptyLabel: 'All creators have complete data',
          tileBuilder: (BuildContext context, CreatorEntity creator) => _QualityTile(
            name: creator.name,
            missingChips: _missingForCreator(creator),
            onEdit: () => context.push('/creators/upsert', extra: creator),
            redText: redText,
          ),
        );
      case Entity.duplicateCreator:
        final List<CreatorEntity>? creators = ref.watch(creatorsStreamProvider).value;

        if (creators == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<CreatorEntity> duplicates = _getDuplicateCreators(creators);

        if (duplicates.isEmpty) {
          return _QualityListView<CreatorEntity>(
            items: duplicates,
            emptyLabel: 'No duplicate creators found',
            tileBuilder: (BuildContext context, CreatorEntity creator) => const SizedBox.shrink(),
          );
        }

        final List<CreatorEntity> sortedAndFiltered = duplicates
            .where((CreatorEntity c) {
              if (_searchQuery.isEmpty) {
                return true;
              }
              return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
            })
            .toList()
          ..sort((CreatorEntity a, CreatorEntity b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        return _buildLayout<CreatorEntity>(
          items: sortedAndFiltered,
          emptyLabel: 'No duplicate creators found',
          tileBuilder: (BuildContext context, CreatorEntity creator) => _QualityTile(
            name: creator.name,
            missingChips: const <String>['Duplicate Name'],
            onEdit: () => context.push('/creators/upsert', extra: creator),
            redText: redText,
          ),
        );
      case Entity.publisher:
        final List<PublisherEntity>? publishers = ref.watch(publishersStreamProvider).value;

        if (publishers == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<PublisherEntity> incomplete = publishers
            .where((PublisherEntity p) => _missingForPublisher(p).isNotEmpty)
            .toList();

        if (incomplete.isEmpty) {
          return _QualityListView<PublisherEntity>(
            items: incomplete,
            emptyLabel: 'All publishers have complete data',
            tileBuilder: (BuildContext context, PublisherEntity publisher) => const SizedBox.shrink(),
          );
        }

        final List<PublisherEntity> sortedAndFiltered = incomplete
            .where((PublisherEntity p) {
              if (_searchQuery.isEmpty) {
                return true;
              }
              return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
            })
            .toList()
          ..sort((PublisherEntity a, PublisherEntity b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        return _buildLayout<PublisherEntity>(
          items: sortedAndFiltered,
          emptyLabel: 'All publishers have complete data',
          tileBuilder: (BuildContext context, PublisherEntity publisher) => _QualityTile(
            name: publisher.name,
            missingChips: _missingForPublisher(publisher),
            onEdit: () => context.push('/publishers/upsert', extra: publisher),
            redText: redText,
          ),
        );
      case Entity.reader:
        final List<ReaderEntity>? readers = ref.watch(readersStreamProvider).value;

        if (readers == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<ReaderEntity> incomplete = readers
            .where((ReaderEntity r) => _missingForReader(r).isNotEmpty)
            .toList();

        if (incomplete.isEmpty) {
          return _QualityListView<ReaderEntity>(
            items: incomplete,
            emptyLabel: 'All readers have complete data',
            tileBuilder: (BuildContext context, ReaderEntity reader) => const SizedBox.shrink(),
          );
        }

        final List<ReaderEntity> sortedAndFiltered = incomplete
            .where((ReaderEntity r) {
              if (_searchQuery.isEmpty) {
                return true;
              }
              return r.name.toLowerCase().contains(_searchQuery.toLowerCase());
            })
            .toList()
          ..sort((ReaderEntity a, ReaderEntity b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        return _buildLayout<ReaderEntity>(
          items: sortedAndFiltered,
          emptyLabel: 'All readers have complete data',
          tileBuilder: (BuildContext context, ReaderEntity reader) => _QualityTile(
            name: reader.name,
            missingChips: _missingForReader(reader),
            onEdit: () => context.push('/readers/upsert', extra: reader),
            redText: redText,
          ),
        );
      case Entity.sequence:
        final List<SequenceEntity>? sequences = ref.watch(sequencesStreamProvider).value;

        if (sequences == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<SequenceEntity> incomplete = sequences
            .where((SequenceEntity s) => _missingForSequence(s).isNotEmpty)
            .toList();

        if (incomplete.isEmpty) {
          return _QualityListView<SequenceEntity>(
            items: incomplete,
            emptyLabel: 'All sequences have complete data',
            tileBuilder: (BuildContext context, SequenceEntity sequence) => const SizedBox.shrink(),
          );
        }

        final List<SequenceEntity> sortedAndFiltered = incomplete
            .where((SequenceEntity s) {
              if (_searchQuery.isEmpty) {
                return true;
              }
              return s.name.toLowerCase().contains(_searchQuery.toLowerCase());
            })
            .toList()
          ..sort((SequenceEntity a, SequenceEntity b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        return _buildLayout<SequenceEntity>(
          items: sortedAndFiltered,
          emptyLabel: 'All sequences have complete data',
          tileBuilder: (BuildContext context, SequenceEntity sequence) => _QualityTile(
            name: sequence.name,
            missingChips: _missingForSequence(sequence),
            onEdit: () => context.push('/sequences/upsert', extra: sequence),
            redText: redText,
          ),
        );
      case Entity.sequenceVolume:
        final List<SequenceVolumeEntity>? sequenceVolumes = ref
            .watch(allSequenceVolumesStreamProvider)
            .value;

        if (sequenceVolumes == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<SequenceVolumeEntity> incomplete = sequenceVolumes
            .where((SequenceVolumeEntity sv) => _missingForSequenceVolume(sv).isNotEmpty)
            .toList();

        if (incomplete.isEmpty) {
          return _QualityListView<SequenceVolumeEntity>(
            items: incomplete,
            emptyLabel: 'All sequence volumes have complete data',
            tileBuilder: (BuildContext context, SequenceVolumeEntity sequenceVolume) => const SizedBox.shrink(),
          );
        }

        final List<SequenceVolumeEntity> sortedAndFiltered = incomplete
            .where((SequenceVolumeEntity sv) {
              if (_searchQuery.isEmpty) {
                return true;
              }
              return sv.volume.toLowerCase().contains(_searchQuery.toLowerCase());
            })
            .toList()
          ..sort((SequenceVolumeEntity a, SequenceVolumeEntity b) => a.volume.toLowerCase().compareTo(b.volume.toLowerCase()));

        return _buildLayout<SequenceVolumeEntity>(
          items: sortedAndFiltered,
          emptyLabel: 'All sequence volumes have complete data',
          tileBuilder: (BuildContext context, SequenceVolumeEntity sequenceVolume) => _QualityTile(
            name: sequenceVolume.volume,
            missingChips: _missingForSequenceVolume(sequenceVolume),
            onEdit: () => context.push('/sequence_volumes/upsert', extra: sequenceVolume),
            redText: redText,
          ),
        );
    }
  }

  Widget _buildLayout<T>({
    required List<T> items,
    required Widget Function(BuildContext context, T item) tileBuilder,
    required String emptyLabel,
  }) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      children: <Widget>[
        SearchField(
          onChanged: (String val) {
            setState(() {
              _searchQuery = val;
            });
          },
        ),
        if (items.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'No results match your search.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
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
