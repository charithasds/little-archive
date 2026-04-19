import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/enums/content_category.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_date_field.dart';
import '../../../../core/shared/presentation/widgets/form_dropdown_field.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/search_multi_picker_field.dart';
import '../../../../core/shared/presentation/widgets/search_picker_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../author/domain/entities/author_entity.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../author/presentation/widgets/add_author_dialog.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../book/presentation/widgets/add_book_dialog.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../sequence/presentation/widgets/add_sequence_dialog.dart';
import '../../../sequence/presentation/widgets/sequence_number_dialog.dart';
import '../../../translator/domain/entities/translator_entity.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../../translator/presentation/widgets/add_translator_dialog.dart';
import '../../domain/entities/work_entity.dart';
import '../providers/upsert_work_controller.dart';

class UpsertWorkPage extends ConsumerStatefulWidget {
  const UpsertWorkPage({super.key, this.existingWork});

  final WorkEntity? existingWork;

  @override
  ConsumerState<UpsertWorkPage> createState() => _UpsertWorkPageState();
}

class _UpsertWorkPageState extends ConsumerState<UpsertWorkPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noOfPagesController = TextEditingController();
  final TextEditingController _originalTitleController = TextEditingController();
  final TextEditingController _pausedPageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Language? _language = Language.sinhala;
  Genre? _genre;
  ContentCategory _contentCategory = ContentCategory.shortStory;
  ReadingStatus _readingStatus = ReadingStatus.notStarted;
  OriginalLanguage? _originalLanguage = OriginalLanguage.english;

  bool _isTranslation = false;
  DateTime? _completedDate;

  List<AuthorEntity> _selectedAuthors = <AuthorEntity>[];
  List<TranslatorEntity> _selectedTranslators = <TranslatorEntity>[];
  BookEntity? _selectedBook;
  Map<SequenceEntity, String> _selectedSequences = <SequenceEntity, String>{};

  bool _isEditingInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingWork != null) {
      final WorkEntity work = widget.existingWork!;
      _titleController.text = work.title;
      _noOfPagesController.text = work.noOfPages?.toString() ?? '';
      _originalTitleController.text = work.originalTitle ?? '';
      _pausedPageController.text = work.pausedPage?.toString() ?? '';
      _notesController.text = work.notes ?? '';
      _language = work.language;
      _genre = work.genre;
      _contentCategory = work.contentCategory;
      _readingStatus = work.readingStatus;
      _originalLanguage = work.originalLanguage;
      _isTranslation = work.isTranslation;
      _completedDate = work.completedDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noOfPagesController.dispose();
    _originalTitleController.dispose();
    _pausedPageController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final WorkEntity? savedWork = await ref
          .read(upsertWorkControllerProvider.notifier)
          .saveWork(
            existingWork: widget.existingWork,
            title: _titleController.text.trim(),
            language: _language,
            genre: _genre,
            contentCategory: _contentCategory,
            noOfPages: int.tryParse(_noOfPagesController.text),
            isTranslation: _isTranslation,
            originalTitle: _isTranslation ? _originalTitleController.text : null,
            originalLanguage: _isTranslation ? _originalLanguage : null,
            readingStatus: _readingStatus,
            pausedPage: int.tryParse(_pausedPageController.text),
            completedDate: _completedDate,
            notes: _notesController.text,
            authorIds: _selectedAuthors.map((AuthorEntity e) => e.id).toList(),
            translatorIds: _selectedTranslators.map((TranslatorEntity e) => e.id).toList(),
            sequenceEntries: _selectedSequences,
            bookId: _selectedBook?.id,
          );

      final bool isSuccess = savedWork != null;

      if (isSuccess && mounted) {
        SnackBars.showSuccess(
          widget.existingWork != null ? 'Work updated successfully' : 'Work added successfully',
        );
        context.pop();
      } else if (!isSuccess && mounted) {
        final UpsertWorkState state = ref.read(upsertWorkControllerProvider);
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
    final UpsertWorkState state = ref.watch(upsertWorkControllerProvider);

    final AsyncValue<List<BookEntity>> booksAsync = ref.watch(booksStreamProvider);
    final AsyncValue<List<SequenceEntity>> sequencesAsync = ref.watch(sequencesStreamProvider);
    final AsyncValue<List<AuthorEntity>> authorsAsync = ref.watch(authorsStreamProvider);
    final AsyncValue<List<TranslatorEntity>> translatorsAsync = ref.watch(
      translatorsStreamProvider,
    );

    if (widget.existingWork != null && !_isEditingInitialized) {
      final String? userId = ref.watch(authStateProvider).value?.uid;
      if (authorsAsync.hasValue &&
          translatorsAsync.hasValue &&
          booksAsync.hasValue &&
          sequencesAsync.hasValue &&
          userId != null) {
        final WorkEntity work = widget.existingWork!;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) {
            return;
          }

          final List<SequenceVolumeEntity> volumes = await ref.read(
            getSequenceVolumesByWorkIdUseCaseProvider,
          )(work.id, userId);

          final Map<SequenceEntity, String> selectedSequences = <SequenceEntity, String>{};
          if (sequencesAsync.value != null) {
            for (final SequenceVolumeEntity volume in volumes) {
              final SequenceEntity? sequence = sequencesAsync.value!
                  .where((SequenceEntity s) => s.id == volume.sequenceId)
                  .firstOrNull;
              if (sequence != null) {
                selectedSequences[sequence] = volume.volume;
              }
            }
          }

          setState(() {
            _selectedAuthors = authorsAsync.value!
                .where((AuthorEntity a) => work.authorIds.contains(a.id))
                .toList();
            _selectedTranslators = translatorsAsync.value!
                .where((TranslatorEntity t) => work.translatorIds.contains(t.id))
                .toList();
            _selectedBook = booksAsync.value!
                .where((BookEntity b) => b.id == work.bookId)
                .firstOrNull;
            _selectedSequences = selectedSequences;
            _isEditingInitialized = true;
          });
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingWork != null ? 'Edit Work' : 'Add Work'),
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
                  onChanged: (bool v) => setState(() => _isTranslation = v),
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
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: Images.getPickerDecoration(
                          theme,
                          image: _selectedBook?.cover != null
                              ? DecorationImage(
                                  image: Images.getImageProvider(_selectedBook!.cover),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedBook?.cover == null
                            ? Icon(
                                Icons.article_rounded,
                                size: 48,
                                color: Images.getPickerIconColor(theme),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    FormTextField(
                      controller: _titleController,
                      label: 'Title',
                      hint: 'Work Title',
                      prefixIcon: Icons.article_rounded,
                      isRequired: true,
                      maxLength: 200,
                    ),
                    const SizedBox(height: 16),

                    FormDropdownField<Language>(
                      value: _language,
                      label: 'Language',
                      prefixIcon: Icons.language_rounded,
                      items: Language.values,
                      itemLabel: (Language e) => e.clientValue,
                      onChanged: (Language? v) => setState(() => _language = v),
                    ),
                    const SizedBox(height: 16),
                    FormDropdownField<Genre>(
                      value: _genre,
                      label: 'Genre',
                      prefixIcon: Icons.theater_comedy_rounded,
                      items: Genre.values,
                      itemLabel: (Genre e) => e.clientValue,
                      onChanged: (Genre? v) => setState(() => _genre = v),
                    ),
                    const SizedBox(height: 16),

                    FormDropdownField<ContentCategory>(
                      value: _contentCategory,
                      label: 'Content Category',
                      prefixIcon: Icons.topic_rounded,
                      items: ContentCategory.values,
                      itemLabel: (ContentCategory e) => e.clientValue,
                      onChanged: (ContentCategory? v) {
                        if (v != null) {
                          setState(() => _contentCategory = v);
                        }
                      },
                      isNullable: false,
                    ),

                    const SizedBox(height: 16),

                    SearchMultiPickerField<AuthorEntity>(
                      label: 'Authors',
                      prefixIcon: Icons.person_rounded,
                      selectedItems: _selectedAuthors,
                      itemsProvider: authorsStreamProvider,
                      itemLabel: (AuthorEntity a) => a.name,
                      itemKey: (AuthorEntity a) => a.id,
                      onChanged: (List<AuthorEntity> l) => setState(() => _selectedAuthors = l),
                      onAdd: () async => showDialog<AuthorEntity>(
                        context: context,
                        builder: (_) => const AddAuthorDialog(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SearchPickerField<BookEntity>(
                      label: 'Book (Anthology/Collection)',
                      prefixIcon: Icons.collections_bookmark_rounded,
                      selectedItem: _selectedBook,
                      itemsProvider: booksStreamProvider,
                      itemLabel: (BookEntity b) => b.title,
                      onChanged: (BookEntity? b) => setState(() => _selectedBook = b),
                      onAdd: () async => showDialog<BookEntity>(
                        context: context,
                        builder: (_) => const AddBookDialog(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SearchMultiPickerField<SequenceEntity>(
                      label: 'Sequences',
                      prefixIcon: Icons.layers_rounded,
                      selectedItems: _selectedSequences.keys.toList(),
                      itemsProvider: sequencesStreamProvider,
                      itemLabel: (SequenceEntity s) => s.name,
                      chipLabel: (SequenceEntity s) => '${s.name} #${_selectedSequences[s]}',
                      itemKey: (SequenceEntity s) => s.id,
                      onChanged: (List<SequenceEntity> list) async {
                        // Wait for the bottom sheet to fully dismiss
                        await Future<void>.delayed(const Duration(milliseconds: 300));
                        if (!mounted) {
                          return;
                        }

                        final Set<String> existingIds =
                            _selectedSequences.keys.map((SequenceEntity s) => s.id).toSet();
                        final List<SequenceEntity> newSequences =
                            list.where((SequenceEntity s) => !existingIds.contains(s.id)).toList();

                        setState(() {
                          _selectedSequences.removeWhere(
                            (SequenceEntity k, _) => !list.contains(k),
                          );
                        });

                        for (final SequenceEntity s in newSequences) {
                          if (!context.mounted) {
                            break;
                          }
                          final String? number = await showDialog<String>(
                            context: context,
                            builder: (_) => SequenceNumberDialog(sequenceName: s.name),
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

                    if (_isTranslation) ...<Widget>[
                      const SizedBox(height: 16),
                      FormTextField(
                        controller: _originalTitleController,
                        label: 'Original Title',
                        prefixIcon: Icons.translate_rounded,
                        maxLength: 200,
                      ),
                      const SizedBox(height: 16),
                      FormDropdownField<OriginalLanguage>(
                        value: _originalLanguage,
                        label: 'Original Language',
                        prefixIcon: Icons.language_rounded,
                        items: OriginalLanguage.values,
                        itemLabel: (OriginalLanguage e) => e.clientValue,
                        onChanged: (OriginalLanguage? v) => setState(() => _originalLanguage = v),
                      ),
                      const SizedBox(height: 16),
                      SearchMultiPickerField<TranslatorEntity>(
                        label: 'Translators',
                        prefixIcon: Icons.translate_rounded,
                        selectedItems: _selectedTranslators,
                        itemsProvider: translatorsStreamProvider,
                        itemLabel: (TranslatorEntity t) => t.name,
                        itemKey: (TranslatorEntity t) => t.id,
                        onChanged: (List<TranslatorEntity> l) =>
                            setState(() => _selectedTranslators = l),
                        onAdd: () async => showDialog<TranslatorEntity>(
                          context: context,
                          builder: (_) => const AddTranslatorDialog(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    FormTextField(
                      controller: _noOfPagesController,
                      label: 'Number of Pages',
                      hint: 'e.g. 99',
                      prefixIcon: Icons.numbers_rounded,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 16),

                    FormDropdownField<ReadingStatus>(
                      value: _readingStatus,
                      label: 'Reading Status',
                      prefixIcon: Icons.menu_book_rounded,
                      items: ReadingStatus.values,
                      itemLabel: (ReadingStatus e) => e.clientValue,
                      onChanged: (ReadingStatus? v) {
                        if (v != null) {
                          setState(() => _readingStatus = v);
                        }
                      },
                      isNullable: false,
                    ),

                    if (_readingStatus == ReadingStatus.paused) ...<Widget>[
                      const SizedBox(height: 16),
                      FormTextField(
                        controller: _pausedPageController,
                        label: 'Paused Page',
                        prefixIcon: Icons.bookmark_border_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ],

                    if (_readingStatus == ReadingStatus.completed) ...<Widget>[
                      const SizedBox(height: 16),
                      FormDateField(
                        label: 'Completed Date',
                        value: _completedDate,
                        onDateSelected: (DateTime d) => setState(() => _completedDate = d),
                        icon: Icons.check_circle_outline_rounded,
                      ),
                    ],

                    const SizedBox(height: 16),
                    FormTextField(
                      controller: _notesController,
                      label: 'Notes',
                      hint: 'Notes about this Work',
                      prefixIcon: Icons.notes_rounded,
                      maxLines: 3,
                      alignLabelWithHint: true,
                    ),

                    const SizedBox(height: 32),

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
                            : (widget.existingWork != null ? 'Update Work' : 'Save Work'),
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
