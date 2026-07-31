import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/scan/scanned_book_entity.dart';
import '../../domain/usecases/book_usecases.dart';

part 'upsert_book_controller.g.dart';

class UpsertBookState {
  const UpsertBookState({
    this.existingBook,
    this.isLoading = false,
    this.isScanning = false,
    this.error,
    this.pickedBase64Image,
    this.scanResult,
  });

  final BookEntity? existingBook;
  final bool isLoading;
  final bool isScanning;
  final String? error;
  final String? pickedBase64Image;
  final ScannedBookEntity? scanResult;

  UpsertBookState copyWith({
    Nullable<BookEntity?>? existingBook,
    bool? isLoading,
    bool? isScanning,
    Nullable<String?>? error,
    Nullable<String?>? pickedBase64Image,
    Nullable<ScannedBookEntity?>? scanResult,
  }) => UpsertBookState(
    existingBook: existingBook != null ? existingBook.value : this.existingBook,
    isLoading: isLoading ?? this.isLoading,
    isScanning: isScanning ?? this.isScanning,
    error: error != null ? error.value : this.error,
    pickedBase64Image: pickedBase64Image != null ? pickedBase64Image.value : this.pickedBase64Image,
    scanResult: scanResult != null ? scanResult.value : this.scanResult,
  );
}

@riverpod
class UpsertBookController extends _$UpsertBookController {
  @override
  UpsertBookState build() => const UpsertBookState();

  void initializeWith(BookEntity? book) {
    state = UpsertBookState(existingBook: book, pickedBase64Image: book?.cover);
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final Uint8List bytes = await pickedFile.readAsBytes();
        final String rawBase64 = base64Encode(bytes);
        final String compressed = Images.compressImageIfNeeded(rawBase64) ?? rawBase64;
        state = state.copyWith(
          pickedBase64Image: Nullable<String?>(compressed),
          error: const Nullable<String?>(null),
        );
      }
    } catch (e) {
      state = state.copyWith(error: Nullable<String?>('Failed to pick image: $e'));
    }
  }

  void setCover(String base64Image) {
    final String compressed = Images.compressImageIfNeeded(base64Image) ?? base64Image;
    state = state.copyWith(pickedBase64Image: Nullable<String?>(compressed));
  }

  void clearCover() {
    state = state.copyWith(pickedBase64Image: const Nullable<String?>(null));
  }

  Future<void> scanBook(Uint8List imageBytes) async {
    state = state.copyWith(
      isScanning: true,
      error: const Nullable<String?>(null),
      scanResult: const Nullable<ScannedBookEntity?>(null),
    );

    try {
      final ScanBookUseCase useCase = ref.read(scanBookUseCaseProvider);
      final ScannedBookEntity result = await useCase.call(imageBytes);

      state = state.copyWith(isScanning: false, scanResult: Nullable<ScannedBookEntity?>(result));
    } catch (e) {
      state = state.copyWith(isScanning: false, error: Nullable<String?>('Scan failed: $e'));
    }
  }

  void clearScanResult() {
    state = state.copyWith(scanResult: const Nullable<ScannedBookEntity?>(null));
  }

  Future<void> retryScan() async {
    final String? base64Image = state.pickedBase64Image;
    if (base64Image == null || base64Image.isEmpty) {
      return;
    }

    state = state.copyWith(
      isScanning: true,
      error: const Nullable<String?>(null),
      scanResult: const Nullable<ScannedBookEntity?>(null),
    );

    try {
      final Uint8List bytes = base64Decode(base64Image);
      await scanBook(bytes);
    } catch (e) {
      state = state.copyWith(isScanning: false, error: Nullable<String?>('Retry failed: $e'));
    }
  }

  Future<BookEntity?> saveBook({
    required String title,
    required CompilationType compilationType,
    required bool isTranslation,
    bool toBeTranslated = false,
    Language? language,
    Genre? genre,
    String? isbn,
    DateTime? publishedDate,
    int? noOfPages,
    String? originalTitle,
    OriginalLanguage? originalLanguage,
    CollectionStatus? collectionStatus,
    DateTime? collectedDate,
    DateTime? lendedDate,
    DateTime? dueDate,
    ReadingStatus? readingStatus,
    int? pausedPage,
    DateTime? completedDate,
    String? notes,
    List<String> authorIds = const <String>[],
    List<String> translatorIds = const <String>[],
    List<String> workIds = const <String>[],
    Map<SequenceEntity, String> sequenceEntries = const <SequenceEntity, String>{},
    String? publisherId,
    String? readerId,
    bool applyToWorks = false,
  }) async {
    state = state.copyWith(isLoading: true, error: const Nullable<String?>(null));

    await Future<void>.delayed(Duration.zero);

    try {
      final BookEntity? existingBook = state.existingBook;
      final String bookId = existingBook?.id ?? ref.read(generateBookIdUseCaseProvider)();
      // Eagerly compress the cover image if it exists to prevent SQLite OOM and large documents.
      final String? compressedCover = Images.compressImageIfNeeded(state.pickedBase64Image);
      if (compressedCover != state.pickedBase64Image) {
        state = state.copyWith(pickedBase64Image: Nullable<String?>(compressedCover));
      }

      final BookEntity bookToSave = existingBook != null
          ? existingBook.copyWith(
              title: title,
              compilationType: compilationType,
              isTranslation: isTranslation,
              toBeTranslated: toBeTranslated,
              cover: Nullable<String?>(compressedCover),
              language: Nullable<Language?>(language),
              genre: Nullable<Genre?>(genre),
              isbn: Nullable<String?>((isbn?.isEmpty ?? true) ? null : isbn),
              publishedDate: Nullable<DateTime?>(publishedDate),
              noOfPages: Nullable<int?>(noOfPages),
              originalTitle: Nullable<String?>(
                (originalTitle?.isEmpty ?? true) ? null : originalTitle,
              ),
              originalLanguage: Nullable<OriginalLanguage?>(originalLanguage),
              collectionStatus: collectionStatus ?? existingBook.collectionStatus,
              collectedDate: Nullable<DateTime?>(collectedDate),
              lendedDate: Nullable<DateTime?>(lendedDate),
              dueDate: Nullable<DateTime?>(dueDate),
              readingStatus: readingStatus ?? existingBook.readingStatus,
              pausedPage: Nullable<int?>(pausedPage),
              completedDate: Nullable<DateTime?>(completedDate),
              notes: Nullable<String?>((notes?.isEmpty ?? true) ? null : notes),
              authorIds: authorIds,
              translatorIds: translatorIds,
              workIds: workIds,
              sequenceVolumeIds: <String>[],
              publisherId: Nullable<String?>(publisherId),
              readerId: Nullable<String?>(readerId),
              lastUpdated: DateTime.now(),
            )
          : BookEntity(
              id: bookId,
              title: title,
              compilationType: compilationType,
              isTranslation: isTranslation,
              toBeTranslated: toBeTranslated,
              cover: compressedCover,
              language: language,
              genre: genre,
              isbn: isbn,
              publishedDate: publishedDate,
              noOfPages: noOfPages,
              originalTitle: isTranslation ? originalTitle : null,
              originalLanguage: isTranslation ? originalLanguage : null,
              collectionStatus: collectionStatus ?? CollectionStatus.collected,
              collectedDate: collectedDate,
              lendedDate: lendedDate,
              dueDate: dueDate,
              readingStatus: readingStatus ?? ReadingStatus.notStarted,
              pausedPage: pausedPage,
              completedDate: completedDate,
              notes: notes,
              authorIds: authorIds,
              translatorIds: translatorIds,
              workIds: workIds,
              sequenceVolumeIds: const <String>[],
              publisherId: publisherId,
              readerId: readerId,
              createdDate: DateTime.now(),
              lastUpdated: DateTime.now(),
            );

      final BookEntity savedBook = await ref.read(upsertBookUseCaseProvider)(
        book: bookToSave,
        sequenceEntries: sequenceEntries,
        isEdit: existingBook != null,
        applyToWorks: applyToWorks,
      );

      state = state.copyWith(isLoading: false);
      return savedBook;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>(e.message));
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>('Error saving book: $e'));
      return null;
    }
  }
}
