import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../author/domain/entities/author_entity.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../../reader/domain/entities/reader_entity.dart';
import '../../../reader/presentation/providers/reader_provider.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../translator/domain/entities/translator_entity.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../../work/domain/entities/work_entity.dart';
import '../../../work/presentation/providers/work_provider.dart';

// ── Tab definition ──────────────────────────────────────────────────────────

enum _DQTab {
  books('Books', Icons.book_rounded),
  works('Works', Icons.article_rounded),
  authors('Authors', Icons.person_rounded),
  translators('Translators', Icons.translate_rounded),
  publishers('Publishers', Icons.business_rounded),
  readers('Readers', Icons.face_rounded),
  sequences('Sequences', Icons.layers_rounded);

  const _DQTab(this.label, this.icon);
  final String label;
  final IconData icon;
}

class DataQualityPage extends ConsumerStatefulWidget {
  const DataQualityPage({super.key});

  @override
  ConsumerState<DataQualityPage> createState() => _DataQualityPageState();
}

class _DataQualityPageState extends ConsumerState<DataQualityPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _DQTab.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: cs.error,
        title: const Text('Data Quality'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: cs.error,
          unselectedLabelColor: cs.onSurfaceVariant,
          indicatorColor: cs.error,
          dividerColor: cs.outlineVariant.withValues(alpha: 0.4),
          tabs: _DQTab.values
              .map(
                (_DQTab t) => Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(t.icon, size: 16),
                      const SizedBox(width: 6),
                      Text(t.label),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          _BooksQualityTab(),
          _WorksQualityTab(),
          _AuthorsQualityTab(),
          _TranslatorsQualityTab(),
          _PublishersQualityTab(),
          _ReadersQualityTab(),
          _SequencesQualityTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Shared widgets ───────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────

/// Shows each entity in a list with missing-field chips and an Edit button.
class _QualityListView<T> extends StatelessWidget {
  const _QualityListView({
    required this.items,
    required this.tileBuilder,
    this.emptyIcon = Icons.check_circle_outline_rounded,
    this.emptyLabel = 'All data complete ✓',
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) tileBuilder;
  final IconData emptyIcon;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      final ThemeData theme = Theme.of(context);
      final ColorScheme cs = theme.colorScheme;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(emptyIcon, size: 64, color: cs.secondary.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(
              emptyLabel,
              style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
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

/// A tile that shows entity name + missing-field chips + Edit button.
class _QualityTile extends StatelessWidget {
  const _QualityTile({required this.name, required this.missingChips, required this.onEdit});

  final String name;
  final List<String> missingChips;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.errorContainer.withValues(alpha: 0.6)),
      ),
      color: cs.errorContainer.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
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
                          (String chip) => Chip(
                            label: Text(chip),
                            labelStyle: theme.textTheme.labelSmall?.copyWith(
                              color: cs.error,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: cs.error.withValues(alpha: 0.1),
                            side: BorderSide(color: cs.error.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              icon: Icon(Icons.edit_note_rounded, color: cs.primary),
              tooltip: 'Edit',
              onPressed: onEdit,
              style: IconButton.styleFrom(
                side: BorderSide(color: cs.outline.withValues(alpha: 0.4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Books tab ────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────

class _BooksQualityTab extends ConsumerWidget {
  const _BooksQualityTab();

  static List<String> _missingFor(BookEntity b) {
    final List<String> missing = <String>[];
    if (b.authorIds.isEmpty && !b.isTranslation) {
      missing.add('No Authors');
    }
    if (b.isTranslation && b.translatorIds.isEmpty) {
      missing.add('No Translators');
    }
    if (b.isTranslation && (b.originalTitle == null || b.originalTitle!.trim().isEmpty)) {
      missing.add('No Original Title');
    }
    if (b.language == null) {
      missing.add('No Language');
    }
    if (b.isTranslation && b.originalLanguage == null) {
      missing.add('No Orig. Language');
    }
    if (b.genre == null) {
      missing.add('No Genre');
    }
    if (b.isbn == null || b.isbn!.trim().isEmpty) {
      missing.add('No ISBN');
    }
    if (b.noOfPages == null) {
      missing.add('No Pages');
    }
    if (b.publisherId == null) {
      missing.add('No Publisher');
    }
    if (b.publishedDate == null) {
      missing.add('No Pub. Date');
    }
    if (b.sequenceVolumeIds.isEmpty) {
      missing.add('No Sequences');
    }
    return missing;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<BookEntity>? books = ref.watch(booksStreamProvider).value;
    if (books == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<BookEntity> incomplete = books
        .where((BookEntity b) => _missingFor(b).isNotEmpty)
        .toList();

    return _QualityListView<BookEntity>(
      items: incomplete,
      emptyLabel: 'All books have complete data ✓',
      tileBuilder: (BuildContext context, BookEntity book) => _QualityTile(
        name: book.title,
        missingChips: _missingFor(book),
        onEdit: () => context.push('/books/add', extra: book),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Works tab ────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────

class _WorksQualityTab extends ConsumerWidget {
  const _WorksQualityTab();

  static List<String> _missingFor(WorkEntity w) {
    final List<String> missing = <String>[];
    if (w.authorIds.isEmpty) {
      missing.add('No Authors');
    }
    if (w.isTranslation && w.translatorIds.isEmpty) {
      missing.add('No Translators');
    }
    if (w.isTranslation && (w.originalTitle == null || w.originalTitle!.trim().isEmpty)) {
      missing.add('No Original Title');
    }
    if (w.language == null) {
      missing.add('No Language');
    }
    if (w.isTranslation && w.originalLanguage == null) {
      missing.add('No Orig. Language');
    }
    if (w.genre == null) {
      missing.add('No Genre');
    }
    if (w.sequenceVolumeIds.isEmpty) {
      missing.add('No Sequences');
    }
    return missing;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<WorkEntity>? works = ref.watch(worksStreamProvider).value;
    if (works == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<WorkEntity> incomplete = works
        .where((WorkEntity w) => _missingFor(w).isNotEmpty)
        .toList();

    return _QualityListView<WorkEntity>(
      items: incomplete,
      emptyLabel: 'All works have complete data ✓',
      tileBuilder: (BuildContext context, WorkEntity work) => _QualityTile(
        name: work.title,
        missingChips: _missingFor(work),
        onEdit: () => context.push('/works/add', extra: work),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Authors tab ──────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────

class _AuthorsQualityTab extends ConsumerWidget {
  const _AuthorsQualityTab();

  static List<String> _missingFor(AuthorEntity a) {
    final List<String> missing = <String>[];
    if (a.image == null || a.image!.trim().isEmpty) {
      missing.add('No Photo');
    }
    if (a.otherName == null || a.otherName!.trim().isEmpty) {
      missing.add('No Alt. Name');
    }
    if (a.website == null || a.website!.trim().isEmpty) {
      missing.add('No Website');
    }
    if (a.bookIds.isEmpty) {
      missing.add('No Books');
    }
    if (a.workIds.isEmpty) {
      missing.add('No Works');
    }
    return missing;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<AuthorEntity>? authors = ref.watch(authorsStreamProvider).value;
    if (authors == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<AuthorEntity> incomplete = authors
        .where((AuthorEntity a) => _missingFor(a).isNotEmpty)
        .toList();

    return _QualityListView<AuthorEntity>(
      items: incomplete,
      emptyLabel: 'All authors have complete data ✓',
      tileBuilder: (BuildContext context, AuthorEntity author) => _QualityTile(
        name: author.name,
        missingChips: _missingFor(author),
        onEdit: () => context.push('/authors/add', extra: author),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Translators tab ──────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────

class _TranslatorsQualityTab extends ConsumerWidget {
  const _TranslatorsQualityTab();

  static List<String> _missingFor(TranslatorEntity t) {
    final List<String> missing = <String>[];
    if (t.image == null || t.image!.trim().isEmpty) {
      missing.add('No Photo');
    }
    if (t.otherName == null || t.otherName!.trim().isEmpty) {
      missing.add('No Alt. Name');
    }
    if (t.website == null || t.website!.trim().isEmpty) {
      missing.add('No Website');
    }
    if (t.bookIds.isEmpty) {
      missing.add('No Books');
    }
    if (t.workIds.isEmpty) {
      missing.add('No Works');
    }
    return missing;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TranslatorEntity>? translators = ref.watch(translatorsStreamProvider).value;
    if (translators == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<TranslatorEntity> incomplete = translators
        .where((TranslatorEntity t) => _missingFor(t).isNotEmpty)
        .toList();

    return _QualityListView<TranslatorEntity>(
      items: incomplete,
      emptyLabel: 'All translators have complete data ✓',
      tileBuilder: (BuildContext context, TranslatorEntity translator) => _QualityTile(
        name: translator.name,
        missingChips: _missingFor(translator),
        onEdit: () => context.push('/translators/add', extra: translator),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Publishers tab ───────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────

class _PublishersQualityTab extends ConsumerWidget {
  const _PublishersQualityTab();

  static List<String> _missingFor(PublisherEntity p) {
    final List<String> missing = <String>[];
    if (p.logo == null || p.logo!.trim().isEmpty) {
      missing.add('No Logo');
    }
    if (p.otherName == null || p.otherName!.trim().isEmpty) {
      missing.add('No Alt. Name');
    }
    if (p.website == null || p.website!.trim().isEmpty) {
      missing.add('No Website');
    }
    if (p.email == null || p.email!.trim().isEmpty) {
      missing.add('No Email');
    }
    if (p.phoneNumber == null || p.phoneNumber!.trim().isEmpty) {
      missing.add('No Phone');
    }
    if (p.bookIds.isEmpty) {
      missing.add('No Books');
    }
    return missing;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<PublisherEntity>? publishers = ref.watch(publishersStreamProvider).value;
    if (publishers == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<PublisherEntity> incomplete = publishers
        .where((PublisherEntity p) => _missingFor(p).isNotEmpty)
        .toList();

    return _QualityListView<PublisherEntity>(
      items: incomplete,
      emptyLabel: 'All publishers have complete data ✓',
      tileBuilder: (BuildContext context, PublisherEntity publisher) => _QualityTile(
        name: publisher.name,
        missingChips: _missingFor(publisher),
        onEdit: () => context.push('/publishers/add', extra: publisher),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Readers tab ──────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────

class _ReadersQualityTab extends ConsumerWidget {
  const _ReadersQualityTab();

  static List<String> _missingFor(ReaderEntity r) {
    final List<String> missing = <String>[];
    if (r.image == null || r.image!.trim().isEmpty) {
      missing.add('No Photo');
    }
    if (r.otherName == null || r.otherName!.trim().isEmpty) {
      missing.add('No Alt. Name');
    }
    if (r.email == null || r.email!.trim().isEmpty) {
      missing.add('No Email');
    }
    if (r.phoneNumber == null || r.phoneNumber!.trim().isEmpty) {
      missing.add('No Phone');
    }
    if (r.bookIds.isEmpty) {
      missing.add('No Books');
    }
    return missing;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ReaderEntity>? readers = ref.watch(readersStreamProvider).value;
    if (readers == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<ReaderEntity> incomplete = readers
        .where((ReaderEntity r) => _missingFor(r).isNotEmpty)
        .toList();

    return _QualityListView<ReaderEntity>(
      items: incomplete,
      emptyLabel: 'All readers have complete data ✓',
      tileBuilder: (BuildContext context, ReaderEntity reader) => _QualityTile(
        name: reader.name,
        missingChips: _missingFor(reader),
        onEdit: () => context.push('/readers/add', extra: reader),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Sequences tab ────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────

class _SequencesQualityTab extends ConsumerWidget {
  const _SequencesQualityTab();

  static List<String> _missingFor(SequenceEntity s) {
    final List<String> missing = <String>[];
    if (s.otherName == null || s.otherName!.trim().isEmpty) {
      missing.add('No Alt. Name');
    }
    if (s.sequenceVolumeIds.isEmpty) {
      missing.add('No Volumes');
    }
    return missing;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<SequenceEntity>? sequences = ref.watch(sequencesStreamProvider).value;
    if (sequences == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<SequenceEntity> incomplete = sequences
        .where((SequenceEntity s) => _missingFor(s).isNotEmpty)
        .toList();

    return _QualityListView<SequenceEntity>(
      items: incomplete,
      emptyLabel: 'All sequences have complete data ✓',
      tileBuilder: (BuildContext context, SequenceEntity sequence) => _QualityTile(
        name: sequence.name,
        missingChips: _missingFor(sequence),
        onEdit: () => context.push('/sequences/add', extra: sequence),
      ),
    );
  }
}
