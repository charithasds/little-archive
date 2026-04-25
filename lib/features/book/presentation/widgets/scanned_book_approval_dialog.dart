import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:string_similarity/string_similarity.dart';

import '../../../author/domain/entities/author_entity.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../translator/domain/entities/translator_entity.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/scanned_book_entity.dart';

class ScannedBookApprovalResult {
  const ScannedBookApprovalResult({
    required this.book,
    required this.selectedAuthors,
    required this.newAuthorNames,
    required this.selectedTranslators,
    required this.newTranslatorNames,
    this.selectedPublisher,
    this.newPublisherName,
  });

  final BookEntity book;
  final List<AuthorEntity> selectedAuthors;
  final List<String> newAuthorNames;
  final List<TranslatorEntity> selectedTranslators;
  final List<String> newTranslatorNames;
  final PublisherEntity? selectedPublisher;
  final String? newPublisherName;
}

class ScannedBookApprovalDialog extends ConsumerStatefulWidget {
  const ScannedBookApprovalDialog({
    super.key,
    required this.scannedBook,
    required this.existingAuthors,
    required this.existingTranslators,
    required this.existingPublishers,
  });

  final ScannedBookEntity scannedBook;
  final List<AuthorEntity> existingAuthors;
  final List<TranslatorEntity> existingTranslators;
  final List<PublisherEntity> existingPublishers;

  @override
  ConsumerState<ScannedBookApprovalDialog> createState() => _ScannedBookApprovalDialogState();
}

class _ScannedBookApprovalDialogState extends ConsumerState<ScannedBookApprovalDialog> {
  final Map<String, bool> _approvals = <String, bool>{};

  late TextEditingController _titleController;
  late TextEditingController _isbnController;
  late TextEditingController _noOfPagesController;
  late TextEditingController _originalTitleController;

  // For authors, translators, publishers
  // Key: detected name, Value: selected existing entity (or "NEW" string, or "IGNORE" null)
  final Map<String, dynamic> _authorSelections = <String, dynamic>{};
  final Map<String, dynamic> _translatorSelections = <String, dynamic>{};
  final Map<String, dynamic> _publisherSelections = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    final BookEntity b = widget.scannedBook.book;

    _titleController = TextEditingController(text: b.title);
    _isbnController = TextEditingController(text: b.isbn ?? '');
    _noOfPagesController = TextEditingController(text: b.noOfPages?.toString() ?? '');
    _originalTitleController = TextEditingController(text: b.originalTitle ?? '');

    if (b.title.isNotEmpty) {
      _approvals['title'] = true;
    }
    _approvals['isTranslation'] = true;
    if (b.isbn != null) {
      _approvals['isbn'] = true;
    }
    if (b.noOfPages != null) {
      _approvals['noOfPages'] = true;
    }
    if (b.originalTitle != null) {
      _approvals['originalTitle'] = true;
    }
    if (b.language != null) {
      _approvals['language'] = true;
    }
    if (b.originalLanguage != null) {
      _approvals['originalLanguage'] = true;
    }
    if (b.genre != null) {
      _approvals['genre'] = true;
    }
    if (b.publishedDate != null) {
      _approvals['publishedDate'] = true;
    }

    // Initialize entity matching
    for (final String name in widget.scannedBook.authorNames) {
      _authorSelections[name] = _findBestMatch(
        name,
        widget.existingAuthors,
        (AuthorEntity a) => a.name,
        (AuthorEntity a) => a.otherName,
      );
    }
    for (final String name in widget.scannedBook.translatorNames) {
      _translatorSelections[name] = _findBestMatch(
        name,
        widget.existingTranslators,
        (TranslatorEntity t) => t.name,
        (TranslatorEntity t) => t.otherName,
      );
    }
    if (widget.scannedBook.publisherName != null) {
      final String name = widget.scannedBook.publisherName!;
      _publisherSelections[name] = _findBestMatch(
        name,
        widget.existingPublishers,
        (PublisherEntity p) => p.name,
        (PublisherEntity p) => null,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _isbnController.dispose();
    _noOfPagesController.dispose();
    _originalTitleController.dispose();
    super.dispose();
  }

  double _similarity(String s1, String s2) =>
      StringSimilarity.compareTwoStrings(s1.toLowerCase().trim(), s2.toLowerCase().trim());

  dynamic _findBestMatch<T>(
    String target,
    List<T> items,
    String Function(T) getName,
    String? Function(T) getOtherName,
  ) {
    T? bestMatch;
    double bestScore = 0.0;

    for (final T item in items) {
      final String name = getName(item);
      final String? otherName = getOtherName(item);

      final double score1 = _similarity(target, name);
      final double score2 = otherName != null ? _similarity(target, otherName) : 0.0;

      final double maxScore = score1 > score2 ? score1 : score2;
      if (maxScore > bestScore && maxScore > 0.85) {
        // Threshold for matching
        bestScore = maxScore;
        bestMatch = item;
      }
    }
    return bestMatch ?? 'NEW';
  }

  Widget _buildMatchSection<T>(
    String detectedName,
    List<T> existingItems,
    String Function(T) getName,
    Map<String, dynamic> selectionsMap,
  ) {
    final dynamic currentSelection = selectionsMap[detectedName];
    final List<T> possibleMatches = existingItems.where((T item) {
      final double score = _similarity(detectedName, getName(item));
      return score > 0.6; // Show decent candidates
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Detected: $detectedName', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: <Widget>[
              ChoiceChip(
                label: const Text('Ignore'),
                selected: currentSelection == 'IGNORE',
                onSelected: (bool selected) {
                  if (selected) {
                    setState(() => selectionsMap[detectedName] = 'IGNORE');
                  }
                },
              ),
              ChoiceChip(
                label: const Text('Create New'),
                selected: currentSelection == 'NEW',
                onSelected: (bool selected) {
                  if (selected) {
                    setState(() => selectionsMap[detectedName] = 'NEW');
                  }
                },
              ),
              for (final T match in possibleMatches)
                ChoiceChip(
                  label: Text('Use: ${getName(match)}'),
                  selected: currentSelection == match,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() => selectionsMap[detectedName] = match);
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTile(String key, String title, TextEditingController controller) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: <Widget>[
        Checkbox(
          value: _approvals[key] ?? false,
          onChanged: (bool? val) {
            if (val != null) {
              setState(() => _approvals[key] = val);
            }
          },
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: title, isDense: true),
            onChanged: (String val) {
              if (!(_approvals[key] ?? false) && val.isNotEmpty) {
                setState(() => _approvals[key] = true);
              }
            },
          ),
        ),
      ],
    ),
  );

  Widget _buildStaticTile(String key, String title, String subtitle) {
    if (!_approvals.containsKey(key)) {
      return const SizedBox.shrink();
    }
    return CheckboxListTile(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      value: _approvals[key] ?? false,
      onChanged: (bool? val) {
        if (val != null) {
          setState(() => _approvals[key] = val);
        }
      },
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final BookEntity b = widget.scannedBook.book;

    return AlertDialog(
      title: const Text('Review Scanned Data'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('Select which fields to auto-fill. You can edit the text before applying.'),
            const SizedBox(height: 16),
            if (_approvals.containsKey('title'))
              _buildEditableTile('title', 'Title', _titleController),
            _buildStaticTile('isTranslation', 'Is Translation?', b.isTranslation ? 'Yes' : 'No'),
            if (_approvals.containsKey('isbn')) _buildEditableTile('isbn', 'ISBN', _isbnController),
            if (_approvals.containsKey('noOfPages'))
              _buildEditableTile('noOfPages', 'Pages', _noOfPagesController),
            if (_approvals.containsKey('originalTitle'))
              _buildEditableTile('originalTitle', 'Original Title', _originalTitleController),
            if (b.language != null)
              _buildStaticTile('language', 'Language', b.language!.clientValue),
            if (b.originalLanguage != null)
              _buildStaticTile(
                'originalLanguage',
                'Original Language',
                b.originalLanguage!.clientValue,
              ),
            if (b.genre != null) _buildStaticTile('genre', 'Genre', b.genre!.clientValue),
            if (b.publishedDate != null)
              _buildStaticTile(
                'publishedDate',
                'Published Date',
                '${b.publishedDate!.year}-${b.publishedDate!.month.toString().padLeft(2, '0')}-${b.publishedDate!.day.toString().padLeft(2, '0')}',
              ),

            if (widget.scannedBook.authorNames.isNotEmpty) ...<Widget>[
              const Divider(height: 32),
              Text('Authors', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final String name in widget.scannedBook.authorNames)
                _buildMatchSection(
                  name,
                  widget.existingAuthors,
                  (AuthorEntity a) => a.name,
                  _authorSelections,
                ),
            ],

            if (widget.scannedBook.translatorNames.isNotEmpty) ...<Widget>[
              const Divider(height: 32),
              Text('Translators', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final String name in widget.scannedBook.translatorNames)
                _buildMatchSection(
                  name,
                  widget.existingTranslators,
                  (TranslatorEntity t) => t.name,
                  _translatorSelections,
                ),
            ],

            if (widget.scannedBook.publisherName != null) ...<Widget>[
              const Divider(height: 32),
              Text('Publisher', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _buildMatchSection(
                widget.scannedBook.publisherName!,
                widget.existingPublishers,
                (PublisherEntity p) => p.name,
                _publisherSelections,
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final BookEntity approvedBook = BookEntity(
              id: b.id,
              title: (_approvals['title'] ?? false) ? _titleController.text : '',
              compilationType: b.compilationType,
              isTranslation: (_approvals['isTranslation'] ?? false) && b.isTranslation,
              isbn: (_approvals['isbn'] ?? false) ? _isbnController.text : null,
              noOfPages: (_approvals['noOfPages'] ?? false)
                  ? int.tryParse(_noOfPagesController.text)
                  : null,
              originalTitle: (_approvals['originalTitle'] ?? false)
                  ? _originalTitleController.text
                  : null,
              language: (_approvals['language'] ?? false) ? b.language : null,
              originalLanguage: (_approvals['originalLanguage'] ?? false)
                  ? b.originalLanguage
                  : null,
              genre: (_approvals['genre'] ?? false) ? b.genre : null,
              publishedDate: (_approvals['publishedDate'] ?? false) ? b.publishedDate : null,
              authorIds: b.authorIds,
              translatorIds: b.translatorIds,
              workIds: b.workIds,
              sequenceVolumeIds: b.sequenceVolumeIds,
              createdDate: b.createdDate,
              lastUpdated: b.lastUpdated,
            );

            final List<AuthorEntity> selectedAuthors = <AuthorEntity>[];
            final List<String> newAuthorNames = <String>[];
            _authorSelections.forEach((String detectedName, dynamic selection) {
              if (selection is AuthorEntity) {
                selectedAuthors.add(selection);
              } else if (selection == 'NEW') {
                newAuthorNames.add(detectedName);
              }
            });

            final List<TranslatorEntity> selectedTranslators = <TranslatorEntity>[];
            final List<String> newTranslatorNames = <String>[];
            _translatorSelections.forEach((String detectedName, dynamic selection) {
              if (selection is TranslatorEntity) {
                selectedTranslators.add(selection);
              } else if (selection == 'NEW') {
                newTranslatorNames.add(detectedName);
              }
            });

            PublisherEntity? selectedPublisher;
            String? newPublisherName;
            _publisherSelections.forEach((String detectedName, dynamic selection) {
              if (selection is PublisherEntity) {
                selectedPublisher = selection;
              } else if (selection == 'NEW') {
                newPublisherName = detectedName;
              }
            });

            final ScannedBookApprovalResult result = ScannedBookApprovalResult(
              book: approvedBook,
              selectedAuthors: selectedAuthors,
              newAuthorNames: newAuthorNames,
              selectedTranslators: selectedTranslators,
              newTranslatorNames: newTranslatorNames,
              selectedPublisher: selectedPublisher,
              newPublisherName: newPublisherName,
            );

            Navigator.of(context).pop(result);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
