import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums/genre.dart';
import '../../../../core/enums/language.dart';
import '../../../../core/enums/original_language.dart';
import '../../../../core/enums/reading_status.dart';
import '../../../../core/enums/work_type.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/form_fields.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../author/domain/entities/author_entity.dart';
import '../../../author/presentation/providers/author_provider.dart';
import '../../../author/presentation/widgets/add_author_dialog.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/domain/repositories/sequence_repository.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../sequence/presentation/widgets/add_sequence_dialog.dart';
import '../../../translator/domain/entities/translator_entity.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../../translator/presentation/widgets/add_translator_dialog.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/repositories/work_repository.dart';
import '../providers/work_provider.dart';

class AddWorkPage extends ConsumerStatefulWidget {
  const AddWorkPage({super.key});

  @override
  ConsumerState<AddWorkPage> createState() => _AddWorkPageState();
}

class _AddWorkPageState extends ConsumerState<AddWorkPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noOfPagesController = TextEditingController();
  final TextEditingController _originalTitleController = TextEditingController();
  final TextEditingController _pausedPageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _sequenceVolumeController = TextEditingController();

  Language _language = Language.english;
  Genre _genre = Genre.fantasy;
  WorkType _workType = WorkType.shortStory;
  ReadingStatus _readingStatus = ReadingStatus.notStarted;
  OriginalLanguage? _originalLanguage;

  bool _isTranslation = false;
  bool _isLoading = false;
  DateTime? _completedDate;

  // Relationships
  List<AuthorEntity> _selectedAuthors = <AuthorEntity>[];
  List<TranslatorEntity> _selectedTranslators = <TranslatorEntity>[];
  BookEntity? _selectedBook;
  SequenceEntity? _selectedSequence;

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
      setState(() => _isLoading = true);

      try {
        final UserEntity? user = ref.read<AsyncValue<UserEntity?>>(authStateProvider).value;
        if (user == null) {
          setState(() => _isLoading = false);
          return;
        }

        final String workId = FirebaseFirestore.instance.collection('works').doc().id;
        String? sequenceVolumeId;

        // Handle Sequence Volume
        if (_selectedSequence != null) {
          if (_sequenceVolumeController.text.isEmpty) {
            SnackBarUtils.showWarning(context, 'Please enter Sequence Volume number');
            setState(() => _isLoading = false);
            return;
          }

          final String volumeId = FirebaseFirestore.instance
              .collection('sequence_volumes')
              .doc()
              .id;
          final SequenceVolumeEntity volume = SequenceVolumeEntity(
            id: volumeId,
            userId: user.uid,
            volume: _sequenceVolumeController.text,
            sequenceId: _selectedSequence!.id,
            workId: workId,
            createdDate: DateTime.now(),
            lastUpdated: DateTime.now(),
          );

          await ref.read<SequenceRepository>(sequenceRepositoryProvider).addSequenceVolume(volume);
          final SequenceEntity updatedSequence = SequenceEntity(
            id: _selectedSequence!.id,
            userId: _selectedSequence!.userId,
            name: _selectedSequence!.name,
            notes: _selectedSequence!.notes,
            sequenceVolumeIds: <String>[..._selectedSequence!.sequenceVolumeIds, volumeId],
          );
          await ref
              .read<SequenceRepository>(sequenceRepositoryProvider)
              .updateSequence(updatedSequence);

          sequenceVolumeId = volumeId;
        }

        final WorkEntity newWork = WorkEntity(
          id: workId,
          userId: user.uid,
          title: _titleController.text.trim(),
          language: _language,
          genre: _genre,
          workType: _workType,
          noOfPages: int.tryParse(_noOfPagesController.text),
          isTranslation: _isTranslation,
          originalTitle: _isTranslation ? _originalTitleController.text : null,
          originalLanguage: _isTranslation ? _originalLanguage : null,
          readingStatus: _readingStatus,
          pausedPage: int.tryParse(_pausedPageController.text),
          completedDate: _completedDate,
          notes: _notesController.text,
          createdDate: DateTime.now(),
          lastUpdated: DateTime.now(),
          authorIds: _selectedAuthors.map((AuthorEntity e) => e.id).toList(),
          translatorIds: _selectedTranslators.map((TranslatorEntity e) => e.id).toList(),
          sequenceVolumeId: sequenceVolumeId,
          bookId: _selectedBook?.id,
        );

        await ref.read<WorkRepository>(workRepositoryProvider).addWork(newWork);
        if (mounted) {
          SnackBarUtils.showSuccess(context, 'Work added successfully');
          Navigator.of(context).pop();
        }
      } on NoConnectionException catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, e.message);
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, 'Error adding work: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context, void Function(DateTime) onPicked) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1000),
      lastDate: DateTime(3000),
    );
    if (picked != null) {
      setState(() {
        onPicked(picked);
      });
    }
  }

  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
    bool alignLabelWithHint = false,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.error),
      ),
    );
  }

  Widget _buildStyledContainer({required Widget child}) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final AsyncValue<List<AuthorEntity>> authorsAsync = ref.watch(authorsStreamProvider);
    final AsyncValue<List<TranslatorEntity>> translatorsAsync = ref.watch(
      translatorsStreamProvider,
    );
    final AsyncValue<List<BookEntity>> booksAsync = ref.watch(booksStreamProvider);
    final AsyncValue<List<SequenceEntity>> sequencesAsync = ref.watch(sequencesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Work'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Header Icon - Shows Book cover if selected
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
                      ? Icon(Icons.article_rounded, size: 48, color: colorScheme.onPrimaryContainer)
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Work title',
                  prefixIcon: const Icon(Icons.title_rounded),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.error, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.error, width: 2),
                  ),
                ),
                maxLength: 500,
                validator: (String? v) => v!.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<Language>(
                initialValue: _language,
                decoration: _buildInputDecoration(
                  label: 'Language',
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
                initialValue: _genre,
                decoration: _buildInputDecoration(
                  label: 'Genre',
                  prefixIcon: Icons.theater_comedy_rounded,
                ),
                items: Genre.values
                    .map((Genre e) => DropdownMenuItem<Genre>(value: e, child: Text(e.clientValue)))
                    .toList(),
                onChanged: (Genre? v) => setState(() => _genre = v!),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<WorkType>(
                initialValue: _workType,
                decoration: _buildInputDecoration(
                  label: 'Work Type',
                  prefixIcon: Icons.category_rounded,
                ),
                items: WorkType.values
                    .map(
                      (WorkType e) =>
                          DropdownMenuItem<WorkType>(value: e, child: Text(e.clientValue)),
                    )
                    .toList(),
                onChanged: (WorkType? v) => setState(() => _workType = v!),
              ),

              _buildSectionHeader('Relationships', Icons.people_rounded),

              // Authors
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
                      builder: (_) => const AddAuthorDialog(),
                    );
                    if (newAuthor != null) {
                      setState(
                        () => _selectedAuthors = <AuthorEntity>[..._selectedAuthors, newAuthor],
                      );
                    }
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object e, StackTrace s) => Text('Error: $e'),
              ),
              const SizedBox(height: 16),

              // Book
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

              // Sequence
              sequencesAsync.when(
                data: (List<SequenceEntity> sequences) => Column(
                  children: <Widget>[
                    SingleSelectField<SequenceEntity>(
                      label: 'Sequence',
                      items: sequences,
                      value: _selectedSequence,
                      itemLabel: (SequenceEntity s) => s.name,
                      itemKey: (SequenceEntity s) => s.id,
                      onChanged: (SequenceEntity? s) => setState(() => _selectedSequence = s),
                      onAdd: () async {
                        final SequenceEntity? newSequence = await showDialog<SequenceEntity>(
                          context: context,
                          builder: (_) => const AddSequenceDialog(),
                        );
                        if (newSequence != null) {
                          setState(() => _selectedSequence = newSequence);
                        }
                      },
                    ),
                    if (_selectedSequence != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: TextFormField(
                          controller: _sequenceVolumeController,
                          decoration: _buildInputDecoration(
                            label: 'Volume Number',
                            hint: 'e.g., 1, 2, 3...',
                            prefixIcon: Icons.format_list_numbered_rounded,
                          ),
                        ),
                      ),
                  ],
                ),
                loading: () => const SizedBox(),
                error: (Object e, StackTrace s) => const SizedBox(),
              ),

              _buildSectionHeader('Details', Icons.info_outline_rounded),

              _buildStyledContainer(
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
                TextFormField(
                  controller: _originalTitleController,
                  decoration: _buildInputDecoration(
                    label: 'Original Title',
                    prefixIcon: Icons.translate_rounded,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<OriginalLanguage>(
                  initialValue: _originalLanguage,
                  decoration: _buildInputDecoration(
                    label: 'Original Language',
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
                  data: (List<TranslatorEntity> translators) => MultiSelectField<TranslatorEntity>(
                    label: 'Translators',
                    allItems: translators,
                    selectedItems: _selectedTranslators,
                    itemLabel: (TranslatorEntity t) => t.name,
                    itemKey: (TranslatorEntity t) => t.id,
                    onChanged: (List<TranslatorEntity> l) =>
                        setState(() => _selectedTranslators = l),
                    onAdd: () async {
                      final TranslatorEntity? newTranslator = await showDialog<TranslatorEntity>(
                        context: context,
                        builder: (_) => const AddTranslatorDialog(),
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
              TextFormField(
                controller: _noOfPagesController,
                decoration: _buildInputDecoration(
                  label: 'Number of Pages',
                  prefixIcon: Icons.numbers_rounded,
                ),
                keyboardType: TextInputType.number,
              ),

              _buildSectionHeader('Status', Icons.bookmark_rounded),

              DropdownButtonFormField<ReadingStatus>(
                initialValue: _readingStatus,
                decoration: _buildInputDecoration(
                  label: 'Reading Status',
                  prefixIcon: Icons.menu_book_rounded,
                ),
                items: ReadingStatus.values
                    .map(
                      (ReadingStatus e) =>
                          DropdownMenuItem<ReadingStatus>(value: e, child: Text(e.clientValue)),
                    )
                    .toList(),
                onChanged: (ReadingStatus? v) => setState(() => _readingStatus = v!),
              ),

              if (_readingStatus == ReadingStatus.paused) ...<Widget>[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pausedPageController,
                  decoration: _buildInputDecoration(
                    label: 'Paused Page',
                    prefixIcon: Icons.bookmark_border_rounded,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],

              if (_readingStatus == ReadingStatus.completed) ...<Widget>[
                const SizedBox(height: 16),
                _buildStyledContainer(
                  child: ListTile(
                    leading: Icon(Icons.check_circle_outline_rounded, color: colorScheme.primary),
                    title: Text(
                      _completedDate == null
                          ? 'Completed Date'
                          : 'Completed: ${DateFormat.yMMMd().format(_completedDate!)}',
                    ),
                    subtitle: _completedDate == null ? const Text('Tap to select') : null,
                    onTap: () => _selectDate(context, (DateTime d) => _completedDate = d),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],

              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: _buildInputDecoration(
                  label: 'Notes',
                  hint: 'Notes about this work',
                  prefixIcon: Icons.notes_rounded,
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Save Button
              FilledButton.icon(
                onPressed: _isLoading ? null : _save,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_isLoading ? 'Saving...' : 'Save Work'),
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
