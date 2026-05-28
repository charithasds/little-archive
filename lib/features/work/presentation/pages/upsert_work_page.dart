import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/content_category.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/presentation/utils/buttons.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../../core/shared/presentation/utils/snack_bars.dart';
import '../../../../core/shared/presentation/widgets/form_dropdown_field.dart';
import '../../../../core/shared/presentation/widgets/form_section.dart';
import '../../../../core/shared/presentation/widgets/form_text_field.dart';
import '../../../../core/shared/presentation/widgets/search_multi_picker_field.dart';
import '../../../../core/shared/presentation/widgets/search_picker_field.dart';
import '../../../../core/theme/presentation/providers/theme_provider.dart';
import '../../../author/domain/entities/author_entity.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../author/presentation/widgets/add_author_bottom_sheet.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../book/presentation/widgets/add_book_bottom_sheet.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/domain/usecases/sequence_volume_usecases.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../sequence/presentation/widgets/add_sequence_bottom_sheet.dart';
import '../../../sequence/presentation/widgets/sequence_number_dialog.dart';
import '../../../translator/domain/entities/translator_entity.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../../translator/presentation/widgets/add_translator_bottom_sheet.dart';
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
  final TextEditingController _originalTitleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Language? _language = Language.sinhala;
  Genre? _genre;
  ContentCategory _contentCategory = ContentCategory.shortStory;
  OriginalLanguage? _originalLanguage = OriginalLanguage.english;

  bool _isTranslation = false;
  bool _toBeTranslated = false;

  List<AuthorEntity> _selectedAuthors = <AuthorEntity>[];
  List<TranslatorEntity> _selectedTranslators = <TranslatorEntity>[];
  BookEntity? _selectedBook;
  Map<SequenceEntity, String> _selectedSequences = <SequenceEntity, String>{};

  bool _isEditingInitialized = false;

  bool get _showOriginalTitle => _isTranslation;
  bool get _showOriginalLanguage => _isTranslation && _showAuthorFields;

  bool get _showLanguageField => _showAuthorFields;

  bool get _showAuthorFields => true;

  bool get _showTranslatorIds => _isTranslation && _showAuthorFields;

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

  @override
  void initState() {
    super.initState();
    if (widget.existingWork != null) {
      final WorkEntity work = widget.existingWork!;
      _titleController.text = work.title;
      _originalTitleController.text = work.originalTitle ?? '';
      _notesController.text = work.notes ?? '';
      _language = work.language;
      _genre = work.genre;
      _contentCategory = work.contentCategory;
      _originalLanguage = work.originalLanguage;
      _isTranslation = work.isTranslation;
      _toBeTranslated = work.toBeTranslated;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upsertWorkControllerProvider.notifier).initializeWith(widget.existingWork);
    });
  }

  void _onBookChanged(BookEntity? b) {
    setState(() {
      _selectedBook = b;
      if (b != null && b.isTranslation) {
        _isTranslation = true;
      }
    });
  }

  void _fillFromBook() {
    if (_selectedBook == null) {
      return;
    }

    final BookEntity b = _selectedBook!;
    final AsyncValue<List<AuthorEntity>> authorsAsync = ref.read(authorsStreamProvider);
    final AsyncValue<List<TranslatorEntity>> translatorsAsync = ref.read(translatorsStreamProvider);

    setState(() {
      if (authorsAsync.hasValue) {
        _selectedAuthors = authorsAsync.value!
            .where((AuthorEntity a) => b.authorIds.contains(a.id))
            .toList();
      }
      if (translatorsAsync.hasValue) {
        _selectedTranslators = translatorsAsync.value!
            .where((TranslatorEntity t) => b.translatorIds.contains(t.id))
            .toList();
      }
      if (b.language != null) {
        _language = b.language;
      }
      if (b.originalLanguage != null) {
        _originalLanguage = b.originalLanguage;
      }
      if (b.isTranslation) {
        _isTranslation = true;
      }
    });

    SnackBars.showSuccess('Details copied from book', context: context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _originalTitleController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final WorkEntity? savedWork = await ref
          .read(upsertWorkControllerProvider.notifier)
          .saveWork(
            title: _titleController.text.trim(),
            contentCategory: _contentCategory,
            isTranslation: _isTranslation,
            toBeTranslated: _toBeTranslated,
            language: _showLanguageField ? _language : null,
            genre: _genre,
            originalTitle: _showOriginalTitle ? _originalTitleController.text : null,
            originalLanguage: _showOriginalLanguage ? _originalLanguage : null,
            notes: _notesController.text,
            authorIds: _showAuthorFields
                ? _selectedAuthors.map((AuthorEntity e) => e.id).toList()
                : <String>[],
            translatorIds: _showTranslatorIds
                ? _selectedTranslators.map((TranslatorEntity e) => e.id).toList()
                : <String>[],
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

    final List<BookEntity> multiWorkBooks =
        booksAsync.value
            ?.where((BookEntity b) => b.compilationType == CompilationType.multiple)
            .toList() ??
        <BookEntity>[];

    if (widget.existingWork != null && !_isEditingInitialized) {
      if (authorsAsync.hasValue &&
          translatorsAsync.hasValue &&
          booksAsync.hasValue &&
          sequencesAsync.hasValue) {
        final WorkEntity work = widget.existingWork!;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) {
            return;
          }

          final List<SequenceVolumeEntity> volumes = await ref.read(
            fetchSequenceVolumesByWorkIdUseCaseProvider,
          )(work.id);

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
            _selectedBook = multiWorkBooks.where((BookEntity b) => b.id == work.bookId).firstOrNull;
            _selectedSequences = selectedSequences;
            _isEditingInitialized = true;
          });
        });
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.existingWork != null ? 'Edit Work' : 'Add Work'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.primary,
        scrolledUnderElevation: 1,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                Icon(Icons.g_translate_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Switch(
                  value: _isTranslation,
                  onChanged: (_selectedBook?.isTranslation ?? false)
                      ? null
                      : _onIsTranslationChanged,
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
            ? Center(child: CircularProgressIndicator(strokeWidth: 3, color: colorScheme.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 140,
                        height: 140 / Images.bookAspectRatio,
                        decoration: Images.getPickerDecoration(
                          theme,
                          shape: ImageShape.rectangle,
                          image: _selectedBook?.cover != null
                              ? DecorationImage(
                                  image: Images.getImageProvider(_selectedBook!.cover),
                                  fit: BoxFit.contain,
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
                    FormSection(
                      title: 'Primary Info',
                      icon: Icons.info_outline_rounded,
                      children: <Widget>[
                        FormTextField(
                          controller: _titleController,
                          label: 'Title',
                          hint: 'Work Title',
                          prefixIcon: Icons.article_rounded,
                          isRequired: true,
                          maxLength: 200,
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
                        if (_showAuthorFields) ...<Widget>[
                          SearchMultiPickerField<AuthorEntity>(
                            label: 'Authors',
                            prefixIcon: Icons.person_rounded,
                            selectedItems: _selectedAuthors,
                            itemsProvider: authorsStreamProvider,
                            itemLabel: (AuthorEntity a) => a.name,
                            itemKey: (AuthorEntity a) => a.id,
                            extraSearchLabels: (AuthorEntity a) => <String?>[a.otherName],
                            onChanged: (List<AuthorEntity> l) =>
                                setState(() => _selectedAuthors = l),
                            onAdd: () async => showModalBottomSheet<AuthorEntity>(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const AddAuthorBottomSheet(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (_showLanguageField) ...<Widget>[
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
                        FormDropdownField<Genre>(
                          value: _genre,
                          label: 'Genre',
                          prefixIcon: Icons.theater_comedy_rounded,
                          items: Genre.values,
                          itemLabel: (Genre e) => e.clientValue,
                          onChanged: (Genre? v) => setState(() => _genre = v),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile.adaptive(
                          value: _toBeTranslated,
                          onChanged: (bool v) => setState(() => _toBeTranslated = v),
                          title: Text(
                            'To Be Translated',
                            style: theme.textTheme.bodyMedium,
                          ),
                          contentPadding: EdgeInsets.zero,
                          secondary: Icon(Icons.g_translate_rounded, color: colorScheme.primary),
                        ),
                      ],
                    ),
                    if (_showTranslatorIds || _showOriginalTitle || _showOriginalLanguage)
                      FormSection(
                        title: 'Translation Info',
                        icon: Icons.translate_rounded,
                        children: <Widget>[
                          if (_showOriginalTitle) ...<Widget>[
                            FormTextField(
                              controller: _originalTitleController,
                              label: 'Original Title',
                              hint: 'Work Original Title',
                              prefixIcon: Icons.translate_rounded,
                              maxLength: 200,
                            ),
                            if (_showTranslatorIds || _showOriginalLanguage)
                              const SizedBox(height: 16),
                          ],
                          if (_showTranslatorIds) ...<Widget>[
                            SearchMultiPickerField<TranslatorEntity>(
                              label: 'Translators',
                              prefixIcon: Icons.translate_rounded,
                              selectedItems: _selectedTranslators,
                              itemsProvider: translatorsStreamProvider,
                              itemLabel: (TranslatorEntity t) => t.name,
                              itemKey: (TranslatorEntity t) => t.id,
                              extraSearchLabels: (TranslatorEntity t) => <String?>[t.otherName],
                              onChanged: (List<TranslatorEntity> l) =>
                                  setState(() => _selectedTranslators = l),
                              onAdd: () async => showModalBottomSheet<TranslatorEntity>(
                                context: context,
                                isScrollControlled: true,
                                useSafeArea: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const AddTranslatorBottomSheet(),
                              ),
                            ),
                            if (_showOriginalLanguage) const SizedBox(height: 16),
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
                    FormSection(
                      title: 'Reference Info',
                      icon: Icons.layers_outlined,
                      children: <Widget>[
                        SearchMultiPickerField<SequenceEntity>(
                          label: 'Sequences',
                          prefixIcon: Icons.layers_rounded,
                          selectedItems: _selectedSequences.keys.toList(),
                          itemsProvider: sequencesStreamProvider,
                          itemLabel: (SequenceEntity s) => s.name,
                          chipLabel: (SequenceEntity s) => '${s.name} #${_selectedSequences[s]}',
                          itemKey: (SequenceEntity s) => s.id,
                          onChanged: (List<SequenceEntity> list) async {
                            await Future<void>.delayed(const Duration(milliseconds: 300));
                            if (!mounted) {
                              return;
                            }

                            final Set<String> existingIds = _selectedSequences.keys
                                .map((SequenceEntity s) => s.id)
                                .toSet();
                            final List<SequenceEntity> newSequences = list
                                .where((SequenceEntity s) => !existingIds.contains(s.id))
                                .toList();

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
                          onAdd: () async => showModalBottomSheet<SequenceEntity>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const AddSequenceBottomSheet(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SearchPickerField<BookEntity>(
                          label: 'Book',
                          prefixIcon: Icons.collections_bookmark_rounded,
                          selectedItem: _selectedBook,
                          itemsProvider: booksStreamProvider,
                          itemLabel: (BookEntity b) => b.title,
                          extraSearchLabels: (BookEntity b) => <String?>[b.originalTitle],
                          filterItems: (List<BookEntity> books) => books
                              .where(
                                (BookEntity b) => b.compilationType == CompilationType.multiple,
                              )
                              .toList(),
                          onChanged: _onBookChanged,
                          onAdd: () async => showModalBottomSheet<BookEntity>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const AddBookBottomSheet(
                              allowedTypes: <CompilationType>[CompilationType.multiple],
                            ),
                          ),
                        ),
                        if (_selectedBook != null) ...<Widget>[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _fillFromBook,
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              label: const Text('Fill from Book'),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                textStyle: theme.textTheme.labelMedium,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    FormSection(
                      title: 'Additional Information',
                      icon: Icons.notes_rounded,
                      children: <Widget>[
                        FormTextField(
                          controller: _notesController,
                          label: 'Notes',
                          hint: 'Notes about this Work',
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
