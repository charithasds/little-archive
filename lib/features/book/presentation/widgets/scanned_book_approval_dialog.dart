import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:string_similarity/string_similarity.dart';

import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/presentation/utils/validators.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../creator/domain/entities/creator_entity.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/scan/scanned_book_entity.dart';
import '../../domain/entities/scan/scanned_name_entity.dart';

class ScannedBookApprovalResult {
  const ScannedBookApprovalResult({
    required this.book,
    required this.selectedAuthors,
    required this.newAuthors,
    required this.selectedTranslators,
    required this.newTranslators,
    this.selectedPublisher,
    this.newPublisher,
  });

  final BookEntity book;
  final List<CreatorEntity> selectedAuthors;
  final List<ScannedNameEntity> newAuthors;
  final List<CreatorEntity> selectedTranslators;
  final List<ScannedNameEntity> newTranslators;
  final PublisherEntity? selectedPublisher;
  final ScannedNameEntity? newPublisher;
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
  final List<CreatorEntity> existingAuthors;
  final List<CreatorEntity> existingTranslators;
  final List<PublisherEntity> existingPublishers;

  @override
  ConsumerState<ScannedBookApprovalDialog> createState() => _ScannedBookApprovalDialogState();
}

class _ScannedBookApprovalDialogState extends ConsumerState<ScannedBookApprovalDialog> {
  final Map<String, bool> _approvals = <String, bool>{};

  late TextEditingController _titleController;
  late TextEditingController _isbnController;
  late TextEditingController _originalTitleController;

  // Controllers for editing the names detected by AI
  // Key is the unique "name" from ScannedNameEntity
  final Map<String, TextEditingController> _authorNameControllers =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _authorOtherNameControllers =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _translatorNameControllers =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _translatorOtherNameControllers =
      <String, TextEditingController>{};
  late TextEditingController _publisherNameController;
  late TextEditingController _publisherOtherNameController;

  // Key: detected name string, Value: selected existing entity (or "NEW" string, or "IGNORE" null)
  final Map<String, dynamic> _authorSelections = <String, dynamic>{};
  final Map<String, dynamic> _translatorSelections = <String, dynamic>{};
  final Map<String, dynamic> _publisherSelections = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    final BookEntity b = widget.scannedBook.book;

    _titleController = TextEditingController(text: b.title);
    _isbnController = TextEditingController(text: b.isbn ?? '');
    _originalTitleController = TextEditingController(text: b.originalTitle ?? '');

    if (b.title.isNotEmpty) {
      _approvals['title'] = true;
    }
    _approvals['isTranslation'] = b.isTranslation;
    if (b.isbn != null) {
      _approvals['isbn'] = true;
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

    // Initialize entity matching and controllers
    for (final ScannedNameEntity sn in widget.scannedBook.authors) {
      _authorNameControllers[sn.name] = TextEditingController(text: sn.name);
      _authorOtherNameControllers[sn.name] = TextEditingController(text: sn.otherName ?? '');
      _authorSelections[sn.name] = _findBestMatch(
        sn.name,
        widget.existingAuthors,
        (CreatorEntity a) => a.name,
        (CreatorEntity a) => a.otherName,
      );
    }

    for (final ScannedNameEntity sn in widget.scannedBook.translators) {
      _translatorNameControllers[sn.name] = TextEditingController(text: sn.name);
      _translatorOtherNameControllers[sn.name] = TextEditingController(text: sn.otherName ?? '');
      _translatorSelections[sn.name] = _findBestMatch(
        sn.name,
        widget.existingTranslators,
        (CreatorEntity t) => t.name,
        (CreatorEntity t) => t.otherName,
      );
    }

    if (widget.scannedBook.publisher != null) {
      final ScannedNameEntity sn = widget.scannedBook.publisher!;
      _publisherNameController = TextEditingController(text: sn.name);
      _publisherOtherNameController = TextEditingController(text: sn.otherName ?? '');
      _publisherSelections[sn.name] = _findBestMatch(
        sn.name,
        widget.existingPublishers,
        (PublisherEntity p) => p.name,
        (PublisherEntity p) => null,
      );
    } else {
      _publisherNameController = TextEditingController();
      _publisherOtherNameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _isbnController.dispose();
    _originalTitleController.dispose();
    for (final TextEditingController c in _authorNameControllers.values) {
      c.dispose();
    }
    for (final TextEditingController c in _authorOtherNameControllers.values) {
      c.dispose();
    }
    for (final TextEditingController c in _translatorNameControllers.values) {
      c.dispose();
    }
    for (final TextEditingController c in _translatorOtherNameControllers.values) {
      c.dispose();
    }
    _publisherNameController.dispose();
    _publisherOtherNameController.dispose();
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
        bestScore = maxScore;
        bestMatch = item;
      }
    }
    return bestMatch ?? 'NEW';
  }

  Widget _buildMatchSection<T>({
    required String detectedKey,
    required List<T> existingItems,
    required String Function(T) getName,
    required Map<String, dynamic> selectionsMap,
    required TextEditingController nameController,
    TextEditingController? otherNameController,
  }) {
    final dynamic currentSelection = selectionsMap[detectedKey];
    final List<T> possibleMatches = existingItems.where((T item) {
      final double score = _similarity(detectedKey, getName(item));
      return score > 0.6;
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Detected: $detectedKey', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    setState(() => selectionsMap[detectedKey] = 'IGNORE');
                  }
                },
              ),
              ChoiceChip(
                label: const Text('Create New'),
                selected: currentSelection == 'NEW',
                onSelected: (bool selected) {
                  if (selected) {
                    setState(() => selectionsMap[detectedKey] = 'NEW');
                  }
                },
              ),
              for (final T match in possibleMatches)
                ChoiceChip(
                  label: Text('Use: ${getName(match)}'),
                  selected: currentSelection == match,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() => selectionsMap[detectedKey] = match);
                    }
                  },
                ),
            ],
          ),
          if (currentSelection == 'NEW') ...<Widget>[
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Edit the name in its original language',
                isDense: true,
              ),
            ),
            if (otherNameController != null) ...<Widget>[
              const SizedBox(height: 8),
              TextField(
                controller: otherNameController,
                decoration: const InputDecoration(
                  labelText: 'Other Name',
                  hintText: 'Alternative name',
                  isDense: true,
                ),
              ),
            ],
          ],
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
            maxLength: key == 'isbn' ? 13 : null,
            buildCounter: key == 'isbn'
                ? (
                    BuildContext context, {
                    required int currentLength,
                    required int? maxLength,
                    required bool isFocused,
                  }) {
                    final String text = controller.text;
                    final String clean = text.replaceAll(RegExp(r'[-\s]'), '').toUpperCase();

                    final String label;
                    final bool isValid;
                    if (clean.length <= 10) {
                      label = 'ISBN10';
                      isValid = Validators.isValidIsbn10(clean);
                    } else {
                      label = 'ISBN13';
                      isValid = Validators.isValidIsbn13(clean);
                    }

                    final String emoji = isValid ? '🟢' : '🔴';

                    return Text(
                      '$label $emoji',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    );
                  }
                : null,
            keyboardType: key == 'isbn' ? TextInputType.number : null,
            inputFormatters: key == 'isbn'
                ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
                : null,
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

  Widget _buildStaticTile(String key, String title, String subtitle, ThemeData theme) {
    if (!_approvals.containsKey(key)) {
      return const SizedBox.shrink();
    }
    return CheckboxListTile(
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle, style: TextStyle(color: theme.colorScheme.primary)),
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
    final ThemeData theme = ref.watch(activeThemeDataProvider);

    if (widget.scannedBook.analysisError != null) {
      return AlertDialog(
        icon: FaIcon(FontAwesomeIcons.circleExclamation, color: theme.colorScheme.error, size: 48),
        title: const Text('Scan Failed'),
        content: Text(
          widget.scannedBook.analysisError!,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        actions: <Widget>[TextButton(onPressed: () => context.pop(), child: const Text('OK'))],
      );
    }

    final BookEntity b = widget.scannedBook.book;

    return AlertDialog(
      title: const Text('Review Scanned Data'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('Verify information and edit names if necessary.'),
            const SizedBox(height: 16),
            if (_approvals.containsKey('title'))
              _buildEditableTile('title', 'Title', _titleController),
            if (b.isTranslation)
              _buildStaticTile(
                'isTranslation',
                'Is Translation?',
                b.isTranslation ? 'Yes' : 'No',
                theme,
              ),
            if (_approvals.containsKey('isbn')) _buildEditableTile('isbn', 'ISBN', _isbnController),
            if (_approvals.containsKey('originalTitle'))
              _buildEditableTile('originalTitle', 'Original Title', _originalTitleController),
            if (b.language != null)
              _buildStaticTile('language', 'Language', b.language!.clientValue, theme),
            if (b.originalLanguage != null)
              _buildStaticTile(
                'originalLanguage',
                'Original Language',
                b.originalLanguage!.clientValue,
                theme,
              ),
            if (b.genre != null) _buildStaticTile('genre', 'Genre', b.genre!.clientValue, theme),

            if (widget.scannedBook.authors.isNotEmpty) ...<Widget>[
              const Divider(height: 32),
              Text('Authors', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final ScannedNameEntity sn in widget.scannedBook.authors)
                _buildMatchSection(
                  detectedKey: sn.name,
                  existingItems: widget.existingAuthors,
                  getName: (CreatorEntity a) => a.name,
                  selectionsMap: _authorSelections,
                  nameController: _authorNameControllers[sn.name]!,
                  otherNameController: _authorOtherNameControllers[sn.name],
                ),
            ],

            if ((_approvals['isTranslation'] ?? false) &&
                widget.scannedBook.translators.isNotEmpty) ...<Widget>[
              const Divider(height: 32),
              Text('Translators', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final ScannedNameEntity sn in widget.scannedBook.translators)
                _buildMatchSection(
                  detectedKey: sn.name,
                  existingItems: widget.existingTranslators,
                  getName: (CreatorEntity t) => t.name,
                  selectionsMap: _translatorSelections,
                  nameController: _translatorNameControllers[sn.name]!,
                  otherNameController: _translatorOtherNameControllers[sn.name],
                ),
            ],

            if (widget.scannedBook.publisher != null) ...<Widget>[
              const Divider(height: 32),
              Text('Publisher', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              _buildMatchSection(
                detectedKey: widget.scannedBook.publisher!.name,
                existingItems: widget.existingPublishers,
                getName: (PublisherEntity p) => p.name,
                selectionsMap: _publisherSelections,
                nameController: _publisherNameController,
                otherNameController: _publisherOtherNameController,
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final BookEntity approvedBook = BookEntity(
              id: b.id,
              title: (_approvals['title'] ?? false) ? _titleController.text : '',
              compilationType: b.compilationType,
              isTranslation: _approvals['isTranslation'] ?? false,
              toBeTranslated: false,
              isbn: (_approvals['isbn'] ?? false) ? _isbnController.text : null,
              originalTitle: (_approvals['originalTitle'] ?? false)
                  ? _originalTitleController.text
                  : null,
              language: (_approvals['language'] ?? false) ? b.language : null,
              originalLanguage: (_approvals['originalLanguage'] ?? false)
                  ? b.originalLanguage
                  : null,
              genre: (_approvals['genre'] ?? false) ? b.genre : null,
              collectionStatus: CollectionStatus.collected,
              readingStatus: ReadingStatus.notStarted,
              publishedDate: (_approvals['publishedDate'] ?? false) ? b.publishedDate : null,
              authorIds: b.authorIds,
              translatorIds: b.translatorIds,
              workIds: b.workIds,
              sequenceVolumeIds: b.sequenceVolumeIds,
              createdDate: b.createdDate,
              lastUpdated: b.lastUpdated,
            );

            final List<CreatorEntity> selectedAuthors = <CreatorEntity>[];
            final List<ScannedNameEntity> newAuthors = <ScannedNameEntity>[];
            _authorSelections.forEach((String key, dynamic selection) {
              if (selection is CreatorEntity) {
                selectedAuthors.add(selection);
              } else if (selection == 'NEW') {
                newAuthors.add(
                  ScannedNameEntity(
                    name: _authorNameControllers[key]!.text,
                    otherName: _authorOtherNameControllers[key]!.text.isEmpty
                        ? null
                        : _authorOtherNameControllers[key]!.text,
                  ),
                );
              }
            });

            final List<CreatorEntity> selectedTranslators = <CreatorEntity>[];
            final List<ScannedNameEntity> newTranslators = <ScannedNameEntity>[];
            if (_approvals['isTranslation'] ?? false) {
              _translatorSelections.forEach((String key, dynamic selection) {
                if (selection is CreatorEntity) {
                  selectedTranslators.add(selection);
                } else if (selection == 'NEW') {
                  newTranslators.add(
                    ScannedNameEntity(
                      name: _translatorNameControllers[key]!.text,
                      otherName: _translatorOtherNameControllers[key]!.text.isEmpty
                          ? null
                          : _translatorOtherNameControllers[key]!.text,
                    ),
                  );
                }
              });
            }

            PublisherEntity? selectedPublisher;
            ScannedNameEntity? newPublisher;
            _publisherSelections.forEach((String key, dynamic selection) {
              if (selection is PublisherEntity) {
                selectedPublisher = selection;
              } else if (selection == 'NEW') {
                newPublisher = ScannedNameEntity(
                  name: _publisherNameController.text,
                  otherName: _publisherOtherNameController.text.isEmpty
                      ? null
                      : _publisherOtherNameController.text,
                );
              }
            });

            final ScannedBookApprovalResult result = ScannedBookApprovalResult(
              book: approvedBook,
              selectedAuthors: selectedAuthors,
              newAuthors: newAuthors,
              selectedTranslators: selectedTranslators,
              newTranslators: newTranslators,
              selectedPublisher: selectedPublisher,
              newPublisher: newPublisher,
            );

            context.pop(result);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
