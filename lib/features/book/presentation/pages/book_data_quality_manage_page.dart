import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/entity.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../author/domain/entities/author_entity.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../../reader/domain/entities/reader_entity.dart';
import '../../../reader/presentation/providers/reader_provider.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../translator/domain/entities/translator_entity.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
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
    final List<AuthorEntity>? authors = ref.watch(authorsStreamProvider).value;
    final List<TranslatorEntity>? translators = ref.watch(translatorsStreamProvider).value;
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
        case Entity.author:
          return authors?.where((AuthorEntity a) => _missingForAuthor(a).isNotEmpty).length;
        case Entity.translator:
          return translators
              ?.where((TranslatorEntity t) => _missingForTranslator(t).isNotEmpty)
              .length;
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
                  Icon(entity.icon, size: 16),
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
    this.emptyIcon = Icons.check_circle_outline_rounded,
    this.emptyLabel = 'All data complete',
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) tileBuilder;
  final IconData emptyIcon;
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
            Icon(emptyIcon, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
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
                                Icon(Icons.error_outline_rounded, size: 16, color: redText),
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
              icon: const Icon(Icons.edit_note_rounded),
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

  if (b.cover == null) {
    missing.add('Cover');
  }

  if (b.language == null) {
    missing.add('Language');
  }

  if (b.genre == null) {
    missing.add('Genre');
  }

  if (b.isbn == null || b.isbn!.trim().isEmpty) {
    missing.add('ISBN');
  }

  if (b.publishedDate == null) {
    missing.add('Published Date');
  }

  if (b.noOfPages == null) {
    missing.add('Number of Pages');
  }

  if (b.isTranslation && (b.originalTitle == null || b.originalTitle!.trim().isEmpty)) {
    missing.add('Original Title');
  }

  if (b.isTranslation && b.originalLanguage == null) {
    missing.add('Original Language');
  }

  if ((b.collectionStatus == CollectionStatus.collected ||
          b.collectionStatus == CollectionStatus.lended) &&
      b.collectedDate == null) {
    missing.add('Collected Date');
  }

  if (b.collectionStatus == CollectionStatus.lended && b.lendedDate == null) {
    missing.add('Lended Date');
  }

  if (b.collectionStatus == CollectionStatus.lended && b.dueDate == null) {
    missing.add('Due Date');
  }

  if (b.readingStatus == ReadingStatus.paused && b.pausedPage == null) {
    missing.add('Paused Page');
  }

  if (b.readingStatus == ReadingStatus.completed && b.completedDate == null) {
    missing.add('Completed Date');
  }

  if (b.authorIds.isEmpty) {
    missing.add('Authors');
  }

  if (b.isTranslation && b.translatorIds.isEmpty) {
    missing.add('Translators');
  }

  if (b.publisherId == null) {
    missing.add('Publisher');
  }

  if (b.collectionStatus == CollectionStatus.lended && b.readerId == null) {
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

  if (w.isTranslation && (w.originalTitle == null || w.originalTitle!.trim().isEmpty)) {
    missing.add('Original Title');
  }

  if (w.isTranslation && w.originalLanguage == null) {
    missing.add('Original Language');
  }

  if (w.authorIds.isEmpty) {
    missing.add('Authors');
  }

  if (w.isTranslation && w.translatorIds.isEmpty) {
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

List<String> _missingForAuthor(AuthorEntity a) {
  final List<String> missing = <String>[];

  if (a.image == null) {
    missing.add('Image');
  }

  if (a.otherName == null || a.otherName!.trim().isEmpty) {
    missing.add('Other Name');
  }

  if (a.website == null || a.website!.trim().isEmpty) {
    missing.add('Website');
  }

  if (a.facebook == null || a.facebook!.trim().isEmpty) {
    missing.add('Facebook');
  }

  if (a.bookIds.isEmpty && a.workIds.isEmpty) {
    missing.add('Creations');
  }

  return missing;
}

List<String> _missingForTranslator(TranslatorEntity t) {
  final List<String> missing = <String>[];

  if (t.image == null) {
    missing.add('Image');
  }

  if (t.otherName == null || t.otherName!.trim().isEmpty) {
    missing.add('Other Name');
  }

  if (t.website == null || t.website!.trim().isEmpty) {
    missing.add('Website');
  }

  if (t.facebook == null || t.facebook!.trim().isEmpty) {
    missing.add('Facebook');
  }

  if (t.bookIds.isEmpty && t.workIds.isEmpty) {
    missing.add('Creations');
  }

  return missing;
}

List<String> _missingForPublisher(PublisherEntity p) {
  final List<String> missing = <String>[];

  if (p.logo == null) {
    missing.add('Logo');
  }

  if (p.otherName == null || p.otherName!.trim().isEmpty) {
    missing.add('Other Name');
  }

  if (p.website == null || p.website!.trim().isEmpty) {
    missing.add('Website');
  }

  if (p.email == null || p.email!.trim().isEmpty) {
    missing.add('Email');
  }

  if (p.facebook == null || p.facebook!.trim().isEmpty) {
    missing.add('Facebook');
  }

  if (p.phoneNumber == null || p.phoneNumber!.trim().isEmpty) {
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

class _EntityQualityTab extends ConsumerWidget {
  const _EntityQualityTab({required this.entity});

  final Entity entity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color redText = isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828);

    switch (entity) {
      case Entity.book:
        final List<BookEntity>? books = ref.watch(booksStreamProvider).value;

        if (books == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<BookEntity> incomplete = books
            .where((BookEntity b) => _missingForBook(b).isNotEmpty)
            .toList();

        return _QualityListView<BookEntity>(
          items: incomplete,
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

        return _QualityListView<WorkEntity>(
          items: incomplete,
          emptyLabel: 'All works have complete data',
          tileBuilder: (BuildContext context, WorkEntity work) => _QualityTile(
            name: work.title,
            missingChips: _missingForWork(work),
            onEdit: () => context.push('/works/upsert', extra: work),
            redText: redText,
          ),
        );
      case Entity.author:
        final List<AuthorEntity>? authors = ref.watch(authorsStreamProvider).value;

        if (authors == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<AuthorEntity> incomplete = authors
            .where((AuthorEntity a) => _missingForAuthor(a).isNotEmpty)
            .toList();

        return _QualityListView<AuthorEntity>(
          items: incomplete,
          emptyLabel: 'All authors have complete data',
          tileBuilder: (BuildContext context, AuthorEntity author) => _QualityTile(
            name: author.name,
            missingChips: _missingForAuthor(author),
            onEdit: () => context.push('/authors/upsert', extra: author),
            redText: redText,
          ),
        );
      case Entity.translator:
        final List<TranslatorEntity>? translators = ref.watch(translatorsStreamProvider).value;

        if (translators == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<TranslatorEntity> incomplete = translators
            .where((TranslatorEntity t) => _missingForTranslator(t).isNotEmpty)
            .toList();

        return _QualityListView<TranslatorEntity>(
          items: incomplete,
          emptyLabel: 'All translators have complete data',
          tileBuilder: (BuildContext context, TranslatorEntity translator) => _QualityTile(
            name: translator.name,
            missingChips: _missingForTranslator(translator),
            onEdit: () => context.push('/translators/upsert', extra: translator),
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

        return _QualityListView<PublisherEntity>(
          items: incomplete,
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

        return _QualityListView<ReaderEntity>(
          items: incomplete,
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

        return _QualityListView<SequenceEntity>(
          items: incomplete,
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

        return _QualityListView<SequenceVolumeEntity>(
          items: incomplete,
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
}
