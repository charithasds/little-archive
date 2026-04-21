import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_date_field.dart';
import '../../../../core/shared/presentation/widgets/form_dropdown_field.dart';
import '../../../../core/shared/presentation/widgets/form_section.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/search_multi_picker_field.dart';
import '../../../../core/shared/presentation/widgets/search_picker_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../author/domain/entities/author_entity.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../author/presentation/widgets/add_author_dialog.dart';
import '../../../publisher/domain/entities/publisher_entity.dart';
import '../../../publisher/presentation/providers/publisher_provider.dart';
import '../../../publisher/presentation/widgets/add_publisher_dialog.dart';
import '../../../reader/domain/entities/reader_entity.dart';
import '../../../reader/presentation/providers/reader_provider.dart';
import '../../../reader/presentation/widgets/add_reader_dialog.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../sequence/presentation/widgets/add_sequence_dialog.dart';
import '../../../sequence/presentation/widgets/sequence_number_dialog.dart';
import '../../../translator/domain/entities/translator_entity.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../../translator/presentation/widgets/add_translator_dialog.dart';
import '../../../work/domain/entities/work_entity.dart';
import '../../../work/presentation/providers/work_provider.dart';
import '../../../work/presentation/widgets/add_work_dialog.dart';
import '../../domain/entities/book_entity.dart';
import '../providers/upsert_book_controller.dart';

class UpsertBookPage extends ConsumerStatefulWidget {
  const UpsertBookPage({super.key, this.existingBook});

  final BookEntity? existingBook;

  @override
  ConsumerState<UpsertBookPage> createState() => _UpsertBookPageState();
}

class _UpsertBookPageState extends ConsumerState<UpsertBookPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _noOfPagesController = TextEditingController();
  final TextEditingController _originalTitleController = TextEditingController();
  final TextEditingController _pausedPageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  CompilationType _compilationType = CompilationType.single;
  Language? _language = Language.sinhala;
  Genre? _genre;
  CollectionStatus _collectionStatus = CollectionStatus.collected;
  ReadingStatus _readingStatus = ReadingStatus.notStarted;
  OriginalLanguage? _originalLanguage = OriginalLanguage.english;

  bool _isTranslation = false;

  DateTime? _publishedDate;
  DateTime? _collectedDate;
  DateTime? _lendedDate;
  DateTime? _dueDate;
  DateTime? _completedDate;

  List<AuthorEntity> _selectedAuthors = <AuthorEntity>[];
  List<TranslatorEntity> _selectedTranslators = <TranslatorEntity>[];
  PublisherEntity? _selectedPublisher;
  ReaderEntity? _selectedReader;
  Map<SequenceEntity, String> _selectedSequences = <SequenceEntity, String>{};
  List<WorkEntity> _selectedWorks = <WorkEntity>[];

  bool _isEditingInitialized = false;

  // Whether this book is connected to works (locks compilationType).
  bool get _hasConnectedWorks =>
      widget.existingBook != null && widget.existingBook!.workIds.isNotEmpty;

  // ── Compilation-type field visibility helpers ─────────────────────────────

  bool get _showAuthorIds =>
      _compilationType == CompilationType.single || _compilationType == CompilationType.collection;

  bool get _showGenre => _compilationType == CompilationType.single;

  bool get _showLanguage => _compilationType == CompilationType.single;

  bool get _showOriginalTitle =>
      _isTranslation &&
      (_compilationType == CompilationType.single ||
          _compilationType == CompilationType.collection);

  bool get _showOriginalLanguage => _showOriginalTitle;

  bool get _showTranslatorIds =>
      _isTranslation &&
      (_compilationType == CompilationType.single ||
          _compilationType == CompilationType.collection);

  bool get _showWorkIds =>
      _compilationType == CompilationType.anthology ||
      _compilationType == CompilationType.collection;

  bool get _showSequenceVolumeIds =>
      _compilationType == CompilationType.single || _compilationType == CompilationType.collection;

  // ── Collection-status field visibility helpers ────────────────────────────

  bool get _showCollectedDate =>
      _collectionStatus == CollectionStatus.collected ||
      _collectionStatus == CollectionStatus.lended;

  bool get _showLendedDate => _collectionStatus == CollectionStatus.lended;

  bool get _showDueDate => _collectionStatus == CollectionStatus.lended;

  bool get _showReaderId => _collectionStatus == CollectionStatus.lended;

  // ── Reading-status field visibility helpers ───────────────────────────────

  bool get _showPausedPage => _readingStatus == ReadingStatus.paused;

  bool get _showCompletedDate => _readingStatus == ReadingStatus.completed;

  // ── State-clearing on toggle ──────────────────────────────────────────────

  void _onCompilationTypeChanged(CompilationType v) {
    setState(() {
      _compilationType = v;

      if (!_showAuthorIds) {
        _selectedAuthors = <AuthorEntity>[];
      }
      if (!_showGenre) {
        _genre = null;
      }
      if (!_showLanguage) {
        _language = null;
      }
      if (!_showOriginalTitle) {
        _originalTitleController.clear();
      }
      if (!_showOriginalLanguage) {
        _originalLanguage = null;
      }
      if (!_showTranslatorIds) {
        _selectedTranslators = <TranslatorEntity>[];
      }
      if (!_showWorkIds) {
        _selectedWorks = <WorkEntity>[];
      }
      if (!_showSequenceVolumeIds) {
        _selectedSequences = <SequenceEntity, String>{};
      }
    });
  }

  void _onIsTranslationChanged(bool v) {
    setState(() {
      _isTranslation = v;

      if (!_showOriginalTitle) {
        _originalTitleController.clear();
      }
      if (!_showOriginalLanguage) {
        _originalLanguage = null;
      }
      if (!_showTranslatorIds) {
        _selectedTranslators = <TranslatorEntity>[];
      }
    });
  }

  void _onCollectionStatusChanged(CollectionStatus v) {
    setState(() {
      _collectionStatus = v;

      if (!_showCollectedDate) {
        _collectedDate = null;
      }
      if (!_showLendedDate) {
        _lendedDate = null;
      }
      if (!_showDueDate) {
        _dueDate = null;
      }
      if (!_showReaderId) {
        _selectedReader = null;
      }
    });
  }

  void _onReadingStatusChanged(ReadingStatus v) {
    setState(() {
      _readingStatus = v;

      if (!_showPausedPage) {
        _pausedPageController.clear();
      }
      if (!_showCompletedDate) {
        _completedDate = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingBook != null) {
      final BookEntity book = widget.existingBook!;
      _titleController.text = book.title;
      _isbnController.text = book.isbn ?? '';
      _noOfPagesController.text = book.noOfPages?.toString() ?? '';
      _originalTitleController.text = book.originalTitle ?? '';
      _pausedPageController.text = book.pausedPage?.toString() ?? '';
      _notesController.text = book.notes ?? '';
      _compilationType = book.compilationType;
      _language = book.language;
      _genre = book.genre;
      _collectionStatus = book.collectionStatus;
      _readingStatus = book.readingStatus;
      _originalLanguage = book.originalLanguage;
      _isTranslation = book.isTranslation;
      _publishedDate = book.publishedDate;
      _collectedDate = book.collectedDate;
      _lendedDate = book.lendedDate;
      _dueDate = book.dueDate;
      _completedDate = book.completedDate;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upsertBookControllerProvider.notifier).initializeWith(widget.existingBook);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _isbnController.dispose();
    _noOfPagesController.dispose();
    _originalTitleController.dispose();
    _pausedPageController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final BookEntity? savedBook = await ref
          .read(upsertBookControllerProvider.notifier)
          .saveBook(
            existingBook: widget.existingBook,
            title: _titleController.text.trim(),
            compilationType: _compilationType,
            language: _showLanguage ? _language : null,
            genre: _showGenre ? _genre : null,
            isbn: _isbnController.text.isNotEmpty ? _isbnController.text : null,
            publishedDate: _publishedDate,
            noOfPages: int.tryParse(_noOfPagesController.text),
            isTranslation: _isTranslation,
            originalTitle: _showOriginalTitle ? _originalTitleController.text : null,
            originalLanguage: _showOriginalLanguage ? _originalLanguage : null,
            collectionStatus: _collectionStatus,
            collectedDate: _showCollectedDate ? _collectedDate : null,
            lendedDate: _showLendedDate ? _lendedDate : null,
            dueDate: _showDueDate ? _dueDate : null,
            readingStatus: _readingStatus,
            pausedPage: _showPausedPage ? int.tryParse(_pausedPageController.text) : null,
            completedDate: _showCompletedDate ? _completedDate : null,
            notes: _notesController.text,
            authorIds: _showAuthorIds
                ? _selectedAuthors.map((AuthorEntity e) => e.id).toList()
                : <String>[],
            translatorIds: _showTranslatorIds
                ? _selectedTranslators.map((TranslatorEntity e) => e.id).toList()
                : <String>[],
            workIds: _showWorkIds
                ? _selectedWorks.map((WorkEntity e) => e.id).toList()
                : <String>[],
            sequenceEntries: _showSequenceVolumeIds
                ? _selectedSequences
                : <SequenceEntity, String>{},
            publisherId: _selectedPublisher?.id,
            readerId: _showReaderId ? _selectedReader?.id : null,
          );

      final bool isSuccess = savedBook != null;

      if (isSuccess && mounted) {
        SnackBars.showSuccess(
          widget.existingBook != null ? 'Book updated successfully' : 'Book added successfully',
        );
        context.pop();
      } else if (!isSuccess && mounted) {
        final UpsertBookState state = ref.read(upsertBookControllerProvider);
        if (state.error != null) {
          SnackBars.showError(state.error!);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final UpsertBookState state = ref.watch(upsertBookControllerProvider);

    final AsyncValue<List<AuthorEntity>> authorsAsync = ref.watch(authorsStreamProvider);
    final AsyncValue<List<TranslatorEntity>> translatorsAsync = ref.watch(
      translatorsStreamProvider,
    );
    final AsyncValue<List<WorkEntity>> worksAsync = ref.watch(worksStreamProvider);
    final AsyncValue<List<PublisherEntity>> publishersAsync = ref.watch(publishersStreamProvider);
    final AsyncValue<List<ReaderEntity>> readersAsync = ref.watch(readersStreamProvider);
    final AsyncValue<List<SequenceEntity>> sequencesAsync = ref.watch(sequencesStreamProvider);

    if (widget.existingBook != null && !_isEditingInitialized) {
      final BookEntity book = widget.existingBook!;

      if (authorsAsync.hasValue &&
          translatorsAsync.hasValue &&
          worksAsync.hasValue &&
          publishersAsync.hasValue &&
          readersAsync.hasValue &&
          sequencesAsync.hasValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) {
            return;
          }

          final List<SequenceVolumeEntity> volumes = await ref.read(
            getSequenceVolumesByBookIdUseCaseProvider,
          )(book.id);

          final Map<SequenceEntity, String> sequencesMap = <SequenceEntity, String>{};
          if (sequencesAsync.value != null) {
            for (final SequenceVolumeEntity vol in volumes) {
              final SequenceEntity? seq = sequencesAsync.value!
                  .where((SequenceEntity s) => s.id == vol.sequenceId)
                  .firstOrNull;
              if (seq != null) {
                sequencesMap[seq] = vol.volume;
              }
            }
          }

          setState(() {
            _selectedAuthors = authorsAsync.value!
                .where((AuthorEntity a) => book.authorIds.contains(a.id))
                .toList();
            _selectedTranslators = translatorsAsync.value!
                .where((TranslatorEntity t) => book.translatorIds.contains(t.id))
                .toList();
            _selectedWorks = worksAsync.value!
                .where((WorkEntity w) => book.workIds.contains(w.id))
                .toList();
            _selectedPublisher = publishersAsync.value!
                .where((PublisherEntity p) => p.id == book.publisherId)
                .firstOrNull;
            _selectedReader = readersAsync.value!
                .where((ReaderEntity r) => r.id == book.readerId)
                .firstOrNull;
            _selectedSequences = sequencesMap;
            _isEditingInitialized = true;
          });
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingBook != null ? 'Edit Book' : 'Add Book'),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                Icon(Icons.g_translate_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Switch(
                  value: _isTranslation,
                  onChanged: _onIsTranslationChanged,
                  inactiveThumbColor: colorScheme.onSurfaceVariant,
                  inactiveTrackColor: colorScheme.surfaceContainerHighest,
                  trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // ── Cover header ─────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => ref.read(upsertBookControllerProvider.notifier).pickImage(),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: Images.getPickerDecoration(
                      theme,
                      image: state.pickedBase64Image != null
                          ? DecorationImage(
                              image: Images.getImageProvider(state.pickedBase64Image),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: state.pickedBase64Image == null
                        ? Icon(
                            Icons.book_rounded,
                            size: 48,
                            color: Images.getPickerIconColor(theme),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Wrap(
                  spacing: 12,
                  children: <Widget>[
                    TextButton.icon(
                      onPressed: () => ref.read(upsertBookControllerProvider.notifier).pickImage(),
                      icon: const Icon(Icons.camera_rounded),
                      label: Text(state.pickedBase64Image == null ? 'Add Cover' : 'Change Cover'),
                    ),
                    if (state.pickedBase64Image != null)
                      TextButton.icon(
                        onPressed: () =>
                            ref.read(upsertBookControllerProvider.notifier).clearCover(),
                        icon: const Icon(Icons.delete_rounded),
                        label: const Text('Remove Cover'),
                        style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),


              // 1. Details
              FormSection(
                title: 'Details',
                icon: Icons.info_outline_rounded,
                children: <Widget>[
                  FormTextField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'Book Title',
                    prefixIcon: Icons.book_rounded,
                    isRequired: true,
                    maxLength: 200,
                  ),
                  const SizedBox(height: 16),
                  FormDropdownField<CompilationType>(
                    value: _compilationType,
                    label: 'Compilation Type',
                    prefixIcon: Icons.collections_bookmark_rounded,
                    items: CompilationType.values,
                    itemLabel: (CompilationType e) => e.clientValue,
                    onChanged: _hasConnectedWorks
                        ? null
                        : (CompilationType? v) {
                            if (v != null) {
                              _onCompilationTypeChanged(v);
                            }
                          },
                    isNullable: false,
                  ),
                ],
              ),

              // 2. Translation
              if (_showTranslatorIds || _showOriginalTitle)
                FormSection(
                  title: 'Translation',
                  icon: Icons.translate_rounded,
                  children: <Widget>[
                    if (_showTranslatorIds) ...<Widget>[
                      SearchMultiPickerField<TranslatorEntity>(
                        label: 'Translators',
                        prefixIcon: Icons.translate_rounded,
                        selectedItems: _selectedTranslators,
                        itemsProvider: translatorsStreamProvider,
                        itemLabel: (TranslatorEntity t) => t.name,
                        itemKey: (TranslatorEntity t) => t.id,
                        onChanged: (List<TranslatorEntity> l) =>
                            setState(() => _selectedTranslators = l),
                        onAdd: () async {
                          final TranslatorEntity? newTranslator =
                              await showDialog<TranslatorEntity>(
                            context: context,
                            builder: (_) => const AddTranslatorDialog(),
                          );
                          if (newTranslator != null && context.mounted) {
                            setState(
                              () => _selectedTranslators = <TranslatorEntity>[
                                ..._selectedTranslators,
                                newTranslator,
                              ],
                            );
                          }
                          return null;
                        },
                      ),
                      if (_showOriginalTitle) const SizedBox(height: 16),
                    ],
                    if (_showOriginalTitle)
                      FormTextField(
                        controller: _originalTitleController,
                        label: 'Original Title',
                        hint: 'Book Original Title',
                        prefixIcon: Icons.translate_rounded,
                        maxLength: 200,
                      ),
                  ],
                ),

              // 3. Primary Info
              FormSection(
                title: 'Primary Info',
                icon: Icons.person_outline_rounded,
                children: <Widget>[
                  if (_showAuthorIds) ...<Widget>[
                    SearchMultiPickerField<AuthorEntity>(
                      label: 'Authors',
                      prefixIcon: Icons.person_rounded,
                      selectedItems: _selectedAuthors,
                      itemsProvider: authorsStreamProvider,
                      itemLabel: (AuthorEntity a) => a.name,
                      itemKey: (AuthorEntity a) => a.id,
                      onChanged: (List<AuthorEntity> l) =>
                          setState(() => _selectedAuthors = l),
                      onAdd: () async => showDialog<AuthorEntity>(
                        context: context,
                        builder: (_) => const AddAuthorDialog(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_showLanguage) ...<Widget>[
                    FormDropdownField<Language>(
                      value: _language,
                      label: 'Language',
                      prefixIcon: Icons.language_rounded,
                      items: Language.values,
                      itemLabel: (Language e) => e.clientValue,
                      onChanged: (Language? v) => setState(() => _language = v),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_showOriginalLanguage)
                    FormDropdownField<OriginalLanguage>(
                      value: _originalLanguage,
                      label: 'Original Language',
                      prefixIcon: Icons.language_rounded,
                      items: OriginalLanguage.values,
                      itemLabel: (OriginalLanguage e) => e.clientValue,
                      onChanged: (OriginalLanguage? v) =>
                          setState(() => _originalLanguage = v),
                    ),
                ],
              ),

              // 4. Series & References
              if (_showSequenceVolumeIds || _showWorkIds)
                FormSection(
                  title: 'Series & References',
                  icon: Icons.layers_outlined,
                  children: <Widget>[
                    if (_showSequenceVolumeIds) ...<Widget>[
                      SearchMultiPickerField<SequenceEntity>(
                        label: 'Sequences',
                        prefixIcon: Icons.layers_rounded,
                        selectedItems: _selectedSequences.keys.toList(),
                        itemsProvider: sequencesStreamProvider,
                        itemLabel: (SequenceEntity s) => s.name,
                        chipLabel: (SequenceEntity s) =>
                            '${s.name} #${_selectedSequences[s]}',
                        itemKey: (SequenceEntity s) => s.id,
                        onChanged: (List<SequenceEntity> list) async {
                          await Future<void>.delayed(
                              const Duration(milliseconds: 300));
                          if (!mounted) {
                            return;
                          }

                          final Set<String> existingIds = _selectedSequences
                              .keys
                              .map((SequenceEntity s) => s.id)
                              .toSet();
                          final List<SequenceEntity> newSequences = list
                              .where((SequenceEntity s) =>
                                  !existingIds.contains(s.id))
                              .toList();

                          setState(() {
                            _selectedSequences.removeWhere(
                                (SequenceEntity k, _) => !list.contains(k));
                          });

                          for (final SequenceEntity s in newSequences) {
                            if (!context.mounted) {
                              break;
                            }
                            final String? number = await showDialog<String>(
                              context: context,
                              builder: (_) =>
                                  SequenceNumberDialog(sequenceName: s.name),
                            );
                            if (number != null) {
                              setState(() => _selectedSequences[s] = number);
                            } else {
                              setState(() => _selectedSequences.remove(s));
                            }
                          }
                        },
                        onChipPressed: (SequenceEntity s) async {
                          if (!context.mounted) {
                            return;
                          }
                          final String? number = await showDialog<String>(
                            context: context,
                            builder: (_) => SequenceNumberDialog(
                              initialValue: _selectedSequences[s],
                              sequenceName: s.name,
                            ),
                          );
                          if (number != null && context.mounted) {
                            setState(() => _selectedSequences[s] = number);
                          }
                        },
                        onAdd: () async => showDialog<SequenceEntity>(
                          context: context,
                          builder: (_) => const AddSequenceDialog(),
                        ),
                      ),
                      if (_showWorkIds) const SizedBox(height: 16),
                    ],
                    if (_showWorkIds)
                      SearchMultiPickerField<WorkEntity>(
                        label: 'Works',
                        prefixIcon: Icons.article_rounded,
                        selectedItems: _selectedWorks,
                        itemsProvider: worksStreamProvider,
                        itemLabel: (WorkEntity s) => s.title,
                        itemKey: (WorkEntity w) => w.id,
                        onChanged: (List<WorkEntity> l) =>
                            setState(() => _selectedWorks = l),
                        onAdd: () async => showDialog<WorkEntity>(
                          context: context,
                          builder: (_) => const AddWorkDialog(),
                        ),
                      ),
                  ],
                ),

              // 5. Collection
              FormSection(
                title: 'Collection',
                icon: Icons.inventory_2_outlined,
                children: <Widget>[
                  FormDropdownField<CollectionStatus>(
                    value: _collectionStatus,
                    label: 'Collection Status',
                    prefixIcon: Icons.inventory_rounded,
                    items: CollectionStatus.values,
                    itemLabel: (CollectionStatus e) => e.clientValue,
                    onChanged: (CollectionStatus? v) {
                      if (v != null) {
                        _onCollectionStatusChanged(v);
                      }
                    },
                    isNullable: false,
                  ),
                  if (_showCollectedDate) ...<Widget>[
                    const SizedBox(height: 16),
                    FormDateField(
                      label: 'Collected Date',
                      value: _collectedDate,
                      onDateSelected: (DateTime d) =>
                          setState(() => _collectedDate = d),
                      icon: Icons.inventory_2_rounded,
                    ),
                  ],
                ],
              ),

              // 6. Lending
              if (_showReaderId || _showLendedDate || _showDueDate)
                FormSection(
                  title: 'Lending',
                  icon: Icons.handshake_outlined,
                  children: <Widget>[
                    if (_showReaderId) ...<Widget>[
                      SearchPickerField<ReaderEntity>(
                        label: 'Reader',
                        prefixIcon: Icons.face_rounded,
                        selectedItem: _selectedReader,
                        itemsProvider: readersStreamProvider,
                        itemLabel: (ReaderEntity r) => r.name,
                        onChanged: (ReaderEntity? r) =>
                            setState(() => _selectedReader = r),
                        onAdd: () async => showDialog<ReaderEntity>(
                          context: context,
                          builder: (_) => const AddReaderDialog(),
                        ),
                      ),
                      if (_showLendedDate || _showDueDate)
                        const SizedBox(height: 16),
                    ],
                    if (_showLendedDate) ...<Widget>[
                      FormDateField(
                        label: 'Lended Date',
                        value: _lendedDate,
                        onDateSelected: (DateTime d) =>
                            setState(() => _lendedDate = d),
                        onCleared: () => setState(() => _lendedDate = null),
                        isClearable: true,
                        icon: Icons.handshake_rounded,
                      ),
                      if (_showDueDate) const SizedBox(height: 16),
                    ],
                    if (_showDueDate)
                      FormDateField(
                        label: 'Due Date',
                        value: _dueDate,
                        onDateSelected: (DateTime d) =>
                            setState(() => _dueDate = d),
                        onCleared: () => setState(() => _dueDate = null),
                        isClearable: true,
                        icon: Icons.event_rounded,
                      ),
                  ],
                ),

              // 7. Reading Progress
              FormSection(
                title: 'Reading Progress',
                icon: Icons.auto_stories_outlined,
                children: <Widget>[
                  FormDropdownField<ReadingStatus>(
                    value: _readingStatus,
                    label: 'Reading Status',
                    prefixIcon: Icons.menu_book_rounded,
                    items: ReadingStatus.values,
                    itemLabel: (ReadingStatus e) => e.clientValue,
                    onChanged: (ReadingStatus? v) {
                      if (v != null) {
                        _onReadingStatusChanged(v);
                      }
                    },
                    isNullable: false,
                  ),
                  if (_showPausedPage) ...<Widget>[
                    const SizedBox(height: 16),
                    FormTextField(
                      controller: _pausedPageController,
                      label: 'Paused Page',
                      prefixIcon: Icons.bookmark_border_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  if (_showCompletedDate) ...<Widget>[
                    const SizedBox(height: 16),
                    FormDateField(
                      label: 'Completed Date',
                      value: _completedDate,
                      onDateSelected: (DateTime d) =>
                          setState(() => _completedDate = d),
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ],
                  const SizedBox(height: 16),
                  FormTextField(
                    controller: _noOfPagesController,
                    label: 'Number of Pages',
                    hint: 'e.g. 153',
                    prefixIcon: Icons.numbers_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),

              // 8. Publication Metadata
              FormSection(
                title: 'Publication Metadata',
                icon: Icons.hub_outlined,
                children: <Widget>[
                  if (_showGenre) ...<Widget>[
                    FormDropdownField<Genre>(
                      value: _genre,
                      label: 'Genre',
                      prefixIcon: Icons.theater_comedy_rounded,
                      items: Genre.values,
                      itemLabel: (Genre e) => e.clientValue,
                      onChanged: (Genre? v) => setState(() => _genre = v),
                    ),
                    const SizedBox(height: 16),
                  ],
                  FormTextField(
                    controller: _isbnController,
                    label: 'ISBN',
                    hint: 'e.g. ISBN10 or ISBN13',
                    prefixIcon: Icons.qr_code_rounded,
                    maxLength: 13,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }
                      final String clean =
                          value.replaceAll(RegExp(r'[-\s]'), '').toUpperCase();
                      if (clean.length != 10 && clean.length != 13) {
                        return 'Enter 10 or 13 digits';
                      }
                      if (clean.length == 10) {
                        if (!RegExp(r'^\d{9}[\dX]$').hasMatch(clean)) {
                          return 'Invalid ISBN-10 format';
                        }
                      } else {
                        if (!RegExp(r'^\d{13}$').hasMatch(clean)) {
                          return 'Invalid ISBN-13 format';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SearchPickerField<PublisherEntity>(
                    label: 'Publisher',
                    prefixIcon: Icons.business_rounded,
                    selectedItem: _selectedPublisher,
                    itemsProvider: publishersStreamProvider,
                    itemLabel: (PublisherEntity p) => p.name,
                    onChanged: (PublisherEntity? p) =>
                        setState(() => _selectedPublisher = p),
                    onAdd: () async => showDialog<PublisherEntity>(
                      context: context,
                      builder: (_) => const AddPublisherDialog(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormDateField(
                    label: 'Published Date',
                    value: _publishedDate,
                    onDateSelected: (DateTime d) =>
                        setState(() => _publishedDate = d),
                    icon: Icons.public_rounded,
                  ),
                ],
              ),

              // 9. Additional Information
              FormSection(
                title: 'Additional Information',
                icon: Icons.notes_rounded,
                children: <Widget>[
                  FormTextField(
                    controller: _notesController,
                    label: 'Notes',
                    hint: 'Notes about this Book',
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 3,
                    alignLabelWithHint: true,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              FilledButton.icon(
                onPressed: state.isLoading ? null : _save,
                icon: state.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  state.isLoading
                      ? 'Saving...'
                      : (widget.existingBook != null ? 'Update Book' : 'Save Book'),
                ),
                style: Buttons.getPrimaryFilledButtonStyle(theme),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
