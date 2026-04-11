import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/enums/content_category.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_date_field.dart';
import '../../../../core/shared/presentation/widgets/form_decoration.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/multi_select_field.dart';
import '../../../../core/shared/presentation/widgets/single_select_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../author/domain/entities/author_entity.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../author/presentation/widgets/upsert_author_dialog.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/domain/usecases/sequence_usecases.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../sequence/presentation/widgets/sequence_number_dialog.dart';
import '../../../sequence/presentation/widgets/upsert_sequence_dialog.dart';
import '../../../translator/domain/entities/translator_entity.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../../translator/presentation/widgets/upsert_translator_dialog.dart';
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
  final TextEditingController _sequenceVolumeController = TextEditingController();

  Language _language = Language.english;
  Genre _genre = Genre.fantasy;
  ContentCategory _contentCategory = ContentCategory.shortStory;
  ReadingStatus _readingStatus = ReadingStatus.notStarted;
  OriginalLanguage? _originalLanguage;

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

  Future<void> _handleSequenceSelection(SequenceEntity? s) async {
    if (s == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    final String? number = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => const SequenceNumberDialog(),
    );

    if (number != null) {
      setState(() {
        _selectedSequences[s] = number;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noOfPagesController.dispose();
    _originalTitleController.dispose();
    _pausedPageController.dispose();
    _notesController.dispose();
    _sequenceVolumeController.dispose();
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
            selectedSequences: _selectedSequences,
            bookId: _selectedBook?.id,
          );

      final bool isSuccess = savedWork != null;

      if (isSuccess && mounted) {
        SnackBars.showSuccess(
          context,
          widget.existingWork != null ? 'Work updated successfully' : 'Work added successfully',
        );
        Navigator.of(context).pop();
      } else if (!isSuccess && mounted) {
        final UpsertWorkState state = ref.read(upsertWorkControllerProvider);
        if (state.error != null) {
          SnackBars.showError(context, state.error!);
        }
      }
    }
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    final ColorScheme colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ref.watch(activeThemeDataProvider);
    final ColorScheme colorScheme = theme.colorScheme;
    final UpsertWorkState state = ref.watch(upsertWorkControllerProvider);

    final AsyncValue<List<AuthorEntity>> authorsAsync = ref.watch(authorsStreamProvider);
    final AsyncValue<List<TranslatorEntity>> translatorsAsync = ref.watch(
      translatorsStreamProvider,
    );
    final AsyncValue<List<BookEntity>> booksAsync = ref.watch(booksStreamProvider);
    final AsyncValue<List<SequenceEntity>> sequencesAsync = ref.watch(sequencesStreamProvider);

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
          )(GetSequenceVolumesByWorkIdParams(workId: work.id, userId: userId));

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
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primaryContainer,
                          border: _selectedBook?.cover != null
                              ? Border.all(color: colorScheme.primary, width: 3)
                              : null,
                          image: _selectedBook?.cover != null
                              ? DecorationImage(
                                  image: MemoryImage(base64Decode(_selectedBook!.cover!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedBook?.cover == null
                            ? Icon(
                                Icons.article_rounded,
                                size: 48,
                                color: colorScheme.onPrimaryContainer,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    FormTextField(
                      controller: _titleController,
                      label: 'Title',
                      hint: 'Work title',
                      prefixIcon: Icons.title_rounded,
                      isRequired: true,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<Language>(
                      value: _language,
                      decoration: buildFormDecoration(
                        colorScheme,
                        labelText: 'Language',
                        prefixIcon: Icons.language_rounded,
                      ),
                      items: Language.values
                          .map(
                            (Language e) =>
                                DropdownMenuItem<Language>(value: e, child: Text(e.clientValue)),
                          )
                          .toList(),
                      onChanged: (Language? v) => setState(() => _language = v!),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<Genre>(
                      value: _genre,
                      decoration: buildFormDecoration(
                        colorScheme,
                        labelText: 'Genre',
                        prefixIcon: Icons.theater_comedy_rounded,
                      ),
                      items: Genre.values
                          .map(
                            (Genre e) =>
                                DropdownMenuItem<Genre>(value: e, child: Text(e.clientValue)),
                          )
                          .toList(),
                      onChanged: (Genre? v) => setState(() => _genre = v!),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<ContentCategory>(
                      value: _contentCategory,
                      decoration: buildFormDecoration(
                        colorScheme,
                        labelText: 'Content Category',
                        prefixIcon: Icons.category_rounded,
                      ),
                      items: ContentCategory.values
                          .map(
                            (ContentCategory e) => DropdownMenuItem<ContentCategory>(
                              value: e,
                              child: Text(e.clientValue),
                            ),
                          )
                          .toList(),
                      onChanged: (ContentCategory? v) => setState(() => _contentCategory = v!),
                    ),

                    _buildSectionHeader('Relationships', Icons.people_rounded, theme),

                    authorsAsync.when(
                      data: (List<AuthorEntity> authors) => MultiSelectField<AuthorEntity>(
                        label: 'Authors',
                        allItems: authors,
                        selectedItems: _selectedAuthors,
                        itemLabel: (AuthorEntity a) => a.name,
                        itemKey: (AuthorEntity a) => a.id,
                        onChanged: (List<AuthorEntity> l) => setState(() => _selectedAuthors = l),
                        onAdd: () async {
                          final AuthorEntity? newAuthor = await showDialog<AuthorEntity>(
                            context: context,
                            builder: (_) => const UpsertAuthorDialog(),
                          );
                          if (newAuthor != null) {
                            setState(
                              () =>
                                  _selectedAuthors = <AuthorEntity>[..._selectedAuthors, newAuthor],
                            );
                          }
                        },
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (Object e, StackTrace s) => Text('Error: $e'),
                    ),
                    const SizedBox(height: 16),

                    booksAsync.when(
                      data: (List<BookEntity> books) => SingleSelectField<BookEntity>(
                        label: 'Book (Anthology/Collection)',
                        items: books,
                        value: _selectedBook,
                        itemLabel: (BookEntity b) => b.title,
                        itemKey: (BookEntity b) => b.id,
                        onChanged: (BookEntity? b) => setState(() => _selectedBook = b),
                      ),
                      loading: () => const SizedBox(),
                      error: (Object e, StackTrace s) => const SizedBox(),
                    ),
                    const SizedBox(height: 16),

                    sequencesAsync.when(
                      data: (List<SequenceEntity> sequences) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (_selectedSequences.isNotEmpty) ...<Widget>[
                            Text('Sequences', style: theme.textTheme.titleSmall),
                            const SizedBox(height: 8),
                            InputDecorator(
                              decoration: buildFormDecoration(
                                colorScheme,
                                contentPadding: const EdgeInsets.all(8),
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _selectedSequences.entries
                                    .map(
                                      (MapEntry<SequenceEntity, String> entry) => InputChip(
                                        label: Text('${entry.key.name} #${entry.value}'),
                                        onDeleted: () =>
                                            setState(() => _selectedSequences.remove(entry.key)),
                                        onPressed: () async {
                                          final String? number = await showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                SequenceNumberDialog(initialValue: entry.value),
                                          );
                                          if (number != null) {
                                            setState(() => _selectedSequences[entry.key] = number);
                                          }
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          SingleSelectField<SequenceEntity>(
                            label: 'Add to Sequence',
                            items: sequences
                                .where((SequenceEntity s) => !_selectedSequences.containsKey(s))
                                .toList(),
                            value: null,
                            itemLabel: (SequenceEntity s) => s.name,
                            itemKey: (SequenceEntity s) => s.id,
                            onChanged: _handleSequenceSelection,
                            onAdd: () async {
                              final SequenceEntity? newSequence = await showDialog<SequenceEntity>(
                                context: context,
                                builder: (_) => const UpsertSequenceDialog(),
                              );
                              if (newSequence != null) {
                                await _handleSequenceSelection(newSequence);
                              }
                            },
                          ),
                        ],
                      ),
                      loading: () => const SizedBox(),
                      error: (Object e, StackTrace s) => const SizedBox(),
                    ),

                    _buildSectionHeader('Details', Icons.info_outline_rounded, theme),

                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SwitchListTile(
                        title: const Text('Is Translation?'),
                        subtitle: const Text('Enable if this work is translated'),
                        value: _isTranslation,
                        onChanged: (bool v) => setState(() => _isTranslation = v),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        inactiveThumbColor: colorScheme.onSurfaceVariant,
                        inactiveTrackColor: colorScheme.surfaceContainerHighest,
                        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                    ),

                    if (_isTranslation) ...<Widget>[
                      const SizedBox(height: 16),
                      FormTextField(
                        controller: _originalTitleController,
                        label: 'Original Title',
                        prefixIcon: Icons.translate_rounded,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<OriginalLanguage>(
                        value: _originalLanguage,
                        decoration: buildFormDecoration(
                          colorScheme,
                          labelText: 'Original Language',
                          prefixIcon: Icons.language_rounded,
                        ),
                        items: OriginalLanguage.values
                            .map(
                              (OriginalLanguage e) => DropdownMenuItem<OriginalLanguage>(
                                value: e,
                                child: Text(e.clientValue),
                              ),
                            )
                            .toList(),
                        onChanged: (OriginalLanguage? v) => setState(() => _originalLanguage = v),
                      ),
                      const SizedBox(height: 16),
                      translatorsAsync.when(
                        data: (List<TranslatorEntity> translators) =>
                            MultiSelectField<TranslatorEntity>(
                              label: 'Translators',
                              allItems: translators,
                              selectedItems: _selectedTranslators,
                              itemLabel: (TranslatorEntity t) => t.name,
                              itemKey: (TranslatorEntity t) => t.id,
                              onChanged: (List<TranslatorEntity> l) =>
                                  setState(() => _selectedTranslators = l),
                              onAdd: () async {
                                final TranslatorEntity? newTranslator =
                                    await showDialog<TranslatorEntity>(
                                      context: context,
                                      builder: (_) => const UpsertTranslatorDialog(),
                                    );
                                if (newTranslator != null) {
                                  setState(
                                    () => _selectedTranslators = <TranslatorEntity>[
                                      ..._selectedTranslators,
                                      newTranslator,
                                    ],
                                  );
                                }
                              },
                            ),
                        loading: () => const SizedBox(),
                        error: (Object e, StackTrace s) => const SizedBox(),
                      ),
                    ],

                    const SizedBox(height: 16),
                    FormTextField(
                      controller: _noOfPagesController,
                      label: 'Number of Pages',
                      prefixIcon: Icons.numbers_rounded,
                      keyboardType: TextInputType.number,
                    ),

                    _buildSectionHeader('Status', Icons.bookmark_rounded, theme),

                    DropdownButtonFormField<ReadingStatus>(
                      value: _readingStatus,
                      decoration: buildFormDecoration(
                        colorScheme,
                        labelText: 'Reading Status',
                        prefixIcon: Icons.menu_book_rounded,
                      ),
                      items: ReadingStatus.values
                          .map(
                            (ReadingStatus e) => DropdownMenuItem<ReadingStatus>(
                              value: e,
                              child: Text(e.clientValue),
                            ),
                          )
                          .toList(),
                      onChanged: (ReadingStatus? v) => setState(() => _readingStatus = v!),
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
                      hint: 'Notes about this work',
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
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
