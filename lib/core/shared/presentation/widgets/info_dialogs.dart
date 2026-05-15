import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/author/domain/entities/author_entity.dart';
import '../../../../features/author/presentation/providers/author_provider.dart';
import '../../../../features/book/domain/entities/book_entity.dart';
import '../../../../features/book/presentation/providers/book_provider.dart';
import '../../../../features/publisher/domain/entities/publisher_entity.dart';
import '../../../../features/publisher/presentation/providers/publisher_provider.dart';
import '../../../../features/reader/domain/entities/reader_entity.dart';
import '../../../../features/reader/presentation/providers/reader_provider.dart';
import '../../../../features/sequence/domain/entities/sequence_entity.dart';
import '../../../../features/sequence/presentation/providers/sequence_provider.dart';
import '../../../../features/translator/domain/entities/translator_entity.dart';
import '../../../../features/translator/presentation/providers/translator_provider.dart';
import '../../../../features/work/domain/entities/work_entity.dart';
import '../../../../features/work/presentation/providers/work_provider.dart';
import '../utils/images.dart';
import 'detail_widgets.dart';

class EntityQuickInfoDialog extends ConsumerWidget {
  const EntityQuickInfoDialog({super.key, required this.entityId, required this.entityType});

  final String entityId;
  final String entityType;

  static void show(BuildContext context, String entityId, String entityType) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
          EntityQuickInfoDialog(entityId: entityId, entityType: entityType),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget content;
    String title = '';

    switch (entityType) {
      case 'author':
        final AsyncValue<AuthorEntity?> async = ref.watch(authorProvider(entityId));
        content = async.when(
          data: (AuthorEntity? author) => _AuthorInfo(author: author),
          loading: () => const _Loading(),
          error: (Object e, _) => Text('Error: $e'),
        );
        title = 'Author Info';
      case 'translator':
        final AsyncValue<TranslatorEntity?> async = ref.watch(translatorProvider(entityId));
        content = async.when(
          data: (TranslatorEntity? translator) => _TranslatorInfo(translator: translator),
          loading: () => const _Loading(),
          error: (Object e, _) => Text('Error: $e'),
        );
        title = 'Translator Info';
      case 'reader':
        final AsyncValue<ReaderEntity?> async = ref.watch(readerProvider(entityId));
        content = async.when(
          data: (ReaderEntity? reader) => _ReaderInfo(reader: reader),
          loading: () => const _Loading(),
          error: (Object e, _) => Text('Error: $e'),
        );
        title = 'Reader Info';
      case 'publisher':
        final AsyncValue<PublisherEntity?> async = ref.watch(publisherProvider(entityId));
        content = async.when(
          data: (PublisherEntity? publisher) => _PublisherInfo(publisher: publisher),
          loading: () => const _Loading(),
          error: (Object e, _) => Text('Error: $e'),
        );
        title = 'Publisher Info';
      case 'book':
        final AsyncValue<BookEntity?> async = ref.watch(bookProvider(entityId));
        content = async.when(
          data: (BookEntity? book) => _BookInfo(book: book),
          loading: () => const _Loading(),
          error: (Object e, _) => Text('Error: $e'),
        );
        title = 'Book Info';
      case 'work':
        final AsyncValue<WorkEntity?> async = ref.watch(workProvider(entityId));
        content = async.when(
          data: (WorkEntity? work) => _WorkInfo(work: work),
          loading: () => const _Loading(),
          error: (Object e, _) => Text('Error: $e'),
        );
        title = 'Work Info';
      case 'sequence':
        final AsyncValue<SequenceEntity?> async = ref.watch(sequenceProvider(entityId));
        content = async.when(
          data: (SequenceEntity? sequence) => _SequenceInfo(sequence: sequence),
          loading: () => const _Loading(),
          error: (Object e, _) => Text('Error: $e'),
        );
        title = 'Sequence Info';
      default:
        content = const Text('Unknown entity type');
    }

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title),
      content: SingleChildScrollView(child: SizedBox(width: 450, child: content)),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: CircularProgressIndicator(strokeWidth: 3, color: cs.primary),
      ),
    );
  }
}

class _AuthorInfo extends StatelessWidget {
  const _AuthorInfo({this.author});
  final AuthorEntity? author;
  @override
  Widget build(BuildContext context) {
    if (author == null) {
      return const Text('Author not found');
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _Avatar(image: author!.image, icon: Icons.person_rounded),
        const SizedBox(height: 16),
        Text(
          author!.name,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (author!.otherName != null && author!.otherName!.isNotEmpty)
          Text(
            author!.otherName!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        const Divider(height: 32),
        DetailTile(
          label: 'Books Count',
          value: '${author!.bookIds.length} books',
          icon: Icons.book_rounded,
        ),
        DetailTile(
          label: 'Works Count',
          value: '${author!.workIds.length} works',
          icon: Icons.article_rounded,
        ),
        _Metadata(created: author!.createdDate, updated: author!.lastUpdated),
      ],
    );
  }
}

class _TranslatorInfo extends StatelessWidget {
  const _TranslatorInfo({this.translator});
  final TranslatorEntity? translator;
  @override
  Widget build(BuildContext context) {
    if (translator == null) {
      return const Text('Translator not found');
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _Avatar(image: translator!.image, icon: Icons.translate_rounded),
        const SizedBox(height: 16),
        Text(
          translator!.name,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (translator!.otherName != null && translator!.otherName!.isNotEmpty)
          Text(
            translator!.otherName!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        const Divider(height: 32),
        DetailTile(
          label: 'Books Count',
          value: '${translator!.bookIds.length} books',
          icon: Icons.book_rounded,
        ),
        DetailTile(
          label: 'Works Count',
          value: '${translator!.workIds.length} works',
          icon: Icons.article_rounded,
        ),
        _Metadata(created: translator!.createdDate, updated: translator!.lastUpdated),
      ],
    );
  }
}

class _ReaderInfo extends StatelessWidget {
  const _ReaderInfo({this.reader});
  final ReaderEntity? reader;
  @override
  Widget build(BuildContext context) {
    if (reader == null) {
      return const Text('Reader not found');
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _Avatar(image: reader!.image, icon: Icons.chrome_reader_mode_rounded),
        const SizedBox(height: 16),
        Text(
          reader!.name,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (reader!.otherName != null && reader!.otherName!.isNotEmpty)
          Text(
            reader!.otherName!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        const Divider(height: 32),
        DetailTile(
          label: 'Books Lended',
          value: '${reader!.bookIds.length} books',
          icon: Icons.book_rounded,
        ),
        _Metadata(created: reader!.createdDate, updated: reader!.lastUpdated),
      ],
    );
  }
}

class _PublisherInfo extends StatelessWidget {
  const _PublisherInfo({this.publisher});
  final PublisherEntity? publisher;
  @override
  Widget build(BuildContext context) {
    if (publisher == null) {
      return const Text('Publisher not found');
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _Avatar(image: publisher!.logo, icon: Icons.business_rounded),
        const SizedBox(height: 16),
        Text(
          publisher!.name,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (publisher!.otherName != null && publisher!.otherName!.isNotEmpty)
          Text(
            publisher!.otherName!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        const Divider(height: 32),
        DetailTile(
          label: 'Books Published',
          value: '${publisher!.bookIds.length} books',
          icon: Icons.book_rounded,
        ),
        _Metadata(created: publisher!.createdDate, updated: publisher!.lastUpdated),
      ],
    );
  }
}

class _BookInfo extends StatelessWidget {
  const _BookInfo({this.book});
  final BookEntity? book;
  @override
  Widget build(BuildContext context) {
    if (book == null) {
      return const Text('Book not found');
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _Cover(image: book!.cover),
        const SizedBox(height: 16),
        Text(
          book!.title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        Text(book!.compilationType.clientValue, style: Theme.of(context).textTheme.bodyMedium),
        const Divider(height: 32),
        _Metadata(created: book!.createdDate, updated: book!.lastUpdated),
      ],
    );
  }
}

class _WorkInfo extends StatelessWidget {
  const _WorkInfo({this.work});
  final WorkEntity? work;
  @override
  Widget build(BuildContext context) {
    if (work == null) {
      return const Text('Work not found');
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.article_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          work!.title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        Text(work!.contentCategory.clientValue, style: Theme.of(context).textTheme.bodyMedium),
        const Divider(height: 32),
        _Metadata(created: work!.createdDate, updated: work!.lastUpdated),
      ],
    );
  }
}

class _SequenceInfo extends StatelessWidget {
  const _SequenceInfo({this.sequence});
  final SequenceEntity? sequence;
  @override
  Widget build(BuildContext context) {
    if (sequence == null) {
      return const Text('Sequence not found');
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.layers_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          sequence!.name,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (sequence!.otherName != null && sequence!.otherName!.isNotEmpty)
          Text(
            sequence!.otherName!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        const Divider(height: 32),
        DetailTile(
          label: 'Volumes Count',
          value: '${sequence!.sequenceVolumeIds.length} volumes',
          icon: Icons.layers_rounded,
        ),
        _Metadata(created: sequence!.createdDate, updated: sequence!.lastUpdated),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.image, required this.icon});
  final String? image;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Images.getAvatarBackgroundColor(theme),
        image: image != null && image!.isNotEmpty
            ? DecorationImage(image: Images.getImageProvider(image), fit: BoxFit.contain)
            : null,
      ),
      child: image == null || image!.isEmpty
          ? Icon(icon, color: Images.getAvatarIconColor(theme), size: 60)
          : null,
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({this.image});
  final String? image;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: 140,
      height: 140 / Images.bookAspectRatio,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Images.getAvatarBackgroundColor(theme),
        image: image != null && image!.isNotEmpty
            ? DecorationImage(image: Images.getImageProvider(image), fit: BoxFit.contain)
            : null,
      ),
      child: image == null || image!.isEmpty
          ? Icon(Icons.book_rounded, color: Images.getAvatarIconColor(theme), size: 60)
          : null,
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.created, required this.updated});
  final DateTime created;
  final DateTime updated;
  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      DetailTile(label: 'Created', value: DetailTile.formatDate(created)),
      DetailTile(label: 'Last Updated', value: DetailTile.formatDate(updated)),
    ],
  );
}
