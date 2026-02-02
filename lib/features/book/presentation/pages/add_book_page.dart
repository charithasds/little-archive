import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums/collection_status.dart';
import '../../../../core/enums/compilation_type.dart';
import '../../../../core/enums/genre.dart';
import '../../../../core/enums/language.dart';
import '../../../../core/enums/original_language.dart';
import '../../../../core/enums/reading_status.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/form_fields.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
import '../../../sequence/domain/repositories/sequence_repository.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../../sequence/presentation/widgets/add_sequence_dialog.dart';
import '../../../translator/domain/entities/translator_entity.dart';
import '../../../translator/presentation/providers/translator_provider.dart';
import '../../../translator/presentation/widgets/add_translator_dialog.dart';
import '../../../work/domain/entities/work_entity.dart';
import '../../../work/presentation/providers/work_provider.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../providers/book_provider.dart';

class AddBookPage extends ConsumerStatefulWidget {
  const AddBookPage({super.key});

  @override
  ConsumerState<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends ConsumerState<AddBookPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _noOfPagesController = TextEditingController();
  final TextEditingController _originalTitleController = TextEditingController();
  final TextEditingController _pausedPageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _sequenceVolumeController = TextEditingController();

  // Enums
  CompilationType _compilationType = CompilationType.single;
  Language _language = Language.english;
  Genre _genre = Genre.fantasy;
  CollectionStatus _collectionStatus = CollectionStatus.collected;
  ReadingStatus _readingStatus = ReadingStatus.notStarted;
  OriginalLanguage? _originalLanguage;

  // Booleans
  bool _isTranslation = false;
  bool _isLoading = false;

  // Cover image
  String? _pickedBase64Image;

  // Dates
  DateTime? _publishedDate;
  DateTime? _collectedDate;
  DateTime? _lendedDate;
  DateTime? _dueDate;
  DateTime? _completedDate;

  // Relationships
  List<AuthorEntity> _selectedAuthors = <AuthorEntity>[];
  List<TranslatorEntity> _selectedTranslators = <TranslatorEntity>[];
  PublisherEntity? _selectedPublisher;
  ReaderEntity? _selectedReader;
  SequenceEntity? _selectedSequence;
  List<WorkEntity> _selectedWorks = <WorkEntity>[];

  @override
  void dispose() {
    _titleController.dispose();
    _isbnController.dispose();
    _noOfPagesController.dispose();
    _originalTitleController.dispose();
    _pausedPageController.dispose();
    _notesController.dispose();
    _sequenceVolumeController.dispose();
    super.dispose();
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        _pickedBase64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final UserEntity? user = ref.read<AsyncValue<UserEntity?>>(authStateProvider).value;
        if (user == null) {
          SnackBarUtils.showError(context, 'User not authenticated.');
          setState(() => _isLoading = false);
          return;
        }

        final String bookId = FirebaseFirestore.instance.collection('books').doc().id;
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
            bookId: bookId,
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

        final BookEntity newBook = BookEntity(
          id: bookId,
          userId: user.uid,
          title: _titleController.text.trim(),
          cover: _pickedBase64Image,
          compilationType: _compilationType,
          language: _language,
          genre: _genre,
          isbn: _isbnController.text.isNotEmpty ? _isbnController.text : null,
          publishedDate: _publishedDate,
          noOfPages: int.tryParse(_noOfPagesController.text),
          isTranslation: _isTranslation,
          originalTitle: _isTranslation ? _originalTitleController.text : null,
          originalLanguage: _isTranslation ? _originalLanguage : null,
          collectionStatus: _collectionStatus,
          collectedDate: _collectedDate,
          lendedDate: _lendedDate,
          dueDate: _dueDate,
          readingStatus: _readingStatus,
          pausedPage: int.tryParse(_pausedPageController.text),
          completedDate: _completedDate,
          notes: _notesController.text,
          createdDate: DateTime.now(),
          lastUpdated: DateTime.now(),
          authorIds: _selectedAuthors.map((AuthorEntity e) => e.id).toList(),
          translatorIds: _selectedTranslators.map((TranslatorEntity e) => e.id).toList(),
          workIds: _selectedWorks.map((WorkEntity e) => e.id).toList(),
          sequenceVolumeId: sequenceVolumeId,
          publisherId: _selectedPublisher?.id,
          readerId: _selectedReader?.id,
        );

        await ref.read<BookRepository>(bookRepositoryProvider).addBook(newBook);
        if (mounted) {
          SnackBarUtils.showSuccess(context, 'Book added successfully');
          Navigator.of(context).pop();
        }
      } on NoConnectionException catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, e.message);
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, 'Error adding book: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
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

    // Watch providers
    final AsyncValue<List<AuthorEntity>> authorsAsync = ref.watch(authorsStreamProvider);
    final AsyncValue<List<TranslatorEntity>> translatorsAsync = ref.watch(
      translatorsStreamProvider,
    );
    final AsyncValue<List<PublisherEntity>> publishersAsync = ref.watch(publishersStreamProvider);
    final AsyncValue<List<ReaderEntity>> readersAsync = ref.watch(readersStreamProvider);
    final AsyncValue<List<SequenceEntity>> sequencesAsync = ref.watch(sequencesStreamProvider);
    final AsyncValue<List<WorkEntity>> worksAsync = ref.watch(worksStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Book'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Cover Image Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primaryContainer,
                      border: Border.all(color: colorScheme.primary, width: 3),
                      image: _pickedBase64Image != null
                          ? DecorationImage(
                              image: MemoryImage(base64Decode(_pickedBase64Image!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _pickedBase64Image == null
                        ? Icon(Icons.book_rounded, size: 48, color: colorScheme.onPrimaryContainer)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: Text(_pickedBase64Image == null ? 'Add Cover' : 'Change Cover'),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Book title',
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

              // Basic Enums
              DropdownButtonFormField<CompilationType>(
                initialValue: _compilationType,
                decoration: _buildInputDecoration(
                  label: 'Compilation Type',
                  prefixIcon: Icons.category_rounded,
                ),
                items: CompilationType.values
                    .map(
                      (CompilationType e) =>
                          DropdownMenuItem<CompilationType>(value: e, child: Text(e.clientValue)),
                    )
                    .toList(),
                onChanged: (CompilationType? v) => setState(() => _compilationType = v!),
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

              // Publishers
              publishersAsync.when(
                data: (List<PublisherEntity> publishers) => SingleSelectField<PublisherEntity>(
                  label: 'Publisher',
                  items: publishers,
                  value: _selectedPublisher,
                  itemLabel: (PublisherEntity p) => p.name,
                  itemKey: (PublisherEntity p) => p.id,
                  onChanged: (PublisherEntity? p) => setState(() => _selectedPublisher = p),
                  onAdd: () async {
                    final PublisherEntity? newPublisher = await showDialog<PublisherEntity>(
                      context: context,
                      builder: (_) => const AddPublisherDialog(),
                    );
                    if (newPublisher != null) {
                      setState(() => _selectedPublisher = newPublisher);
                    }
                  },
                ),
                loading: () => const SizedBox(),
                error: (Object e, StackTrace s) => const SizedBox(),
              ),
              const SizedBox(height: 16),

              // Readers
              readersAsync.when(
                data: (List<ReaderEntity> readers) => SingleSelectField<ReaderEntity>(
                  label: 'Reader',
                  items: readers,
                  value: _selectedReader,
                  itemLabel: (ReaderEntity r) => r.name,
                  itemKey: (ReaderEntity r) => r.id,
                  onChanged: (ReaderEntity? r) => setState(() => _selectedReader = r),
                  onAdd: () async {
                    final ReaderEntity? newReader = await showDialog<ReaderEntity>(
                      context: context,
                      builder: (_) => const AddReaderDialog(),
                    );
                    if (newReader != null) {
                      setState(() => _selectedReader = newReader);
                    }
                  },
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
              const SizedBox(height: 16),

              // Works
              worksAsync.when(
                data: (List<WorkEntity> works) => MultiSelectField<WorkEntity>(
                  label: 'Works',
                  allItems: works,
                  selectedItems: _selectedWorks,
                  itemLabel: (WorkEntity s) => s.title,
                  itemKey: (WorkEntity w) => w.id,
                  onChanged: (List<WorkEntity> l) => setState(() => _selectedWorks = l),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object e, StackTrace s) => Text('Error: $e'),
              ),

              _buildSectionHeader('Details', Icons.info_outline_rounded),

              _buildStyledContainer(
                child: SwitchListTile(
                  title: const Text('Is Translation?'),
                  subtitle: const Text('Enable if this book is translated'),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _isbnController,
                decoration: _buildInputDecoration(label: 'ISBN', prefixIcon: Icons.qr_code_rounded),
              ),

              const SizedBox(height: 16),
              _buildStyledContainer(
                child: ListTile(
                  leading: Icon(Icons.calendar_today_rounded, color: colorScheme.primary),
                  title: Text(
                    _publishedDate == null
                        ? 'Published Date'
                        : 'Published: ${DateFormat.yMMMd().format(_publishedDate!)}',
                  ),
                  subtitle: _publishedDate == null ? const Text('Tap to select') : null,
                  onTap: () => _selectDate(context, (DateTime d) => _publishedDate = d),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),

              _buildSectionHeader('Status', Icons.bookmark_rounded),

              DropdownButtonFormField<CollectionStatus>(
                initialValue: _collectionStatus,
                decoration: _buildInputDecoration(
                  label: 'Collection Status',
                  prefixIcon: Icons.inventory_rounded,
                ),
                items: CollectionStatus.values
                    .map(
                      (CollectionStatus e) =>
                          DropdownMenuItem<CollectionStatus>(value: e, child: Text(e.clientValue)),
                    )
                    .toList(),
                onChanged: (CollectionStatus? v) => setState(() => _collectionStatus = v!),
              ),
              const SizedBox(height: 16),

              _buildStyledContainer(
                child: ListTile(
                  leading: Icon(Icons.calendar_today_rounded, color: colorScheme.primary),
                  title: Text(
                    _collectedDate == null
                        ? 'Collected Date'
                        : 'Collected: ${DateFormat.yMMMd().format(_collectedDate!)}',
                  ),
                  subtitle: _collectedDate == null ? const Text('Tap to select') : null,
                  onTap: () => _selectDate(context, (DateTime d) => _collectedDate = d),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),

              // Lended Date
              _buildStyledContainer(
                child: ListTile(
                  leading: Icon(Icons.share_rounded, color: colorScheme.primary),
                  title: Text(
                    _lendedDate == null
                        ? 'Lended Date'
                        : 'Lended: ${DateFormat.yMMMd().format(_lendedDate!)}',
                  ),
                  subtitle: _lendedDate == null ? const Text('Tap to select') : null,
                  trailing: _lendedDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _lendedDate = null),
                        )
                      : null,
                  onTap: () => _selectDate(context, (DateTime d) => _lendedDate = d),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),

              // Due Date
              _buildStyledContainer(
                child: ListTile(
                  leading: Icon(Icons.event_rounded, color: colorScheme.primary),
                  title: Text(
                    _dueDate == null ? 'Due Date' : 'Due: ${DateFormat.yMMMd().format(_dueDate!)}',
                  ),
                  subtitle: _dueDate == null ? const Text('Tap to select') : null,
                  trailing: _dueDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _dueDate = null),
                        )
                      : null,
                  onTap: () => _selectDate(context, (DateTime d) => _dueDate = d),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),

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
                  hint: 'Notes about this book',
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
                label: Text(_isLoading ? 'Saving...' : 'Save Book'),
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
