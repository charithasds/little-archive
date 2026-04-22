import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../domain/entities/book_entity.dart';
import 'book_provider.dart';

part 'upsert_book_controller.g.dart';

class UpsertBookState {
  const UpsertBookState({
    this.existingBook,
    this.isLoading = false,
    this.error,
    this.pickedBase64Image,
  });

  final BookEntity? existingBook;
  final bool isLoading;
  final String? error;
  final String? pickedBase64Image;

  UpsertBookState copyWith({
    Nullable<BookEntity?>? existingBook,
    bool? isLoading,
    Nullable<String?>? error,
    Nullable<String?>? pickedBase64Image,
  }) =>
      UpsertBookState(
        existingBook: existingBook != null ? existingBook.value : this.existingBook,
        isLoading: isLoading ?? this.isLoading,
        error: error != null ? error.value : this.error,
        pickedBase64Image: pickedBase64Image != null ? pickedBase64Image.value : this.pickedBase64Image,
      );
}

@riverpod
class UpsertBookController extends _$UpsertBookController {
  @override
  UpsertBookState build() => const UpsertBookState();

  void initializeWith(BookEntity? book) {
    state = UpsertBookState(
      existingBook: book,
      pickedBase64Image: book?.cover,
    );
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      state = state.copyWith(pickedBase64Image: Nullable<String?>(base64Encode(bytes)));
    }
  }

  void clearCover() {
    state = state.copyWith(pickedBase64Image: const Nullable<String?>(null));
  }

  Future<BookEntity?> saveBook({
    required String title,
    required CompilationType compilationType,
    required bool isTranslation,
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
  }) async {
    state = state.copyWith(isLoading: true, error: const Nullable<String?>(null));

    final UserEntity? user = ref.read(authStateProvider).value;

    if (user == null) {
      state = state.copyWith(isLoading: false, error: const Nullable<String?>('User not authenticated'));
      return null;
    }

    try {
      final BookEntity? existingBook = state.existingBook;
      final String bookId = existingBook?.id ?? ref.read(generateBookIdUseCaseProvider)();
      final List<String> sequenceVolumeIds = <String>[];

      if (existingBook != null) {
        final List<SequenceVolumeEntity> oldVolumes =
            await ref.read(fetchSequenceVolumesByBookIdUseCaseProvider)(bookId);

        for (final SequenceVolumeEntity vol in oldVolumes) {
          await ref.read(removeSequenceVolumeUseCaseProvider)(vol.id);

          final SequenceEntity? seq =
              await ref.read(fetchSequenceByIdUseCaseProvider)(vol.sequenceId);

          if (seq != null) {
            final List<String> newIds = List<String>.from(seq.sequenceVolumeIds)..remove(vol.id);
            await ref
                .read(editSequenceUseCaseProvider)(seq.copyWith(sequenceVolumeIds: newIds));
          }
        }
      }

      for (final MapEntry<SequenceEntity, String> entry in sequenceEntries.entries) {
        final SequenceEntity sequence = entry.key;
        final String volumeNumber = entry.value;

        final String volumeId = ref.read(generateSequenceVolumeIdUseCaseProvider)();
        final SequenceVolumeEntity volume = SequenceVolumeEntity(
          id: volumeId,
          volume: volumeNumber,
          sequenceId: sequence.id,
          bookId: bookId,
          createdDate: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        await ref.read(addSequenceVolumeUseCaseProvider)(volume);

        final SequenceEntity? currentSequence =
            await ref.read(fetchSequenceByIdUseCaseProvider)(sequence.id);

        if (currentSequence != null) {
          final SequenceEntity updatedSequence = currentSequence.copyWith(
            sequenceVolumeIds: <String>[...currentSequence.sequenceVolumeIds, volumeId],
          );
          await ref.read(editSequenceUseCaseProvider)(updatedSequence);
        }

        sequenceVolumeIds.add(volumeId);
      }

      final BookEntity bookToSave =
          existingBook != null
              ? existingBook.copyWith(
                  title: title,
                  compilationType: compilationType,
                  isTranslation: isTranslation,
                  cover: Nullable<String?>(state.pickedBase64Image),
                  language: Nullable<Language?>(language),
                  genre: Nullable<Genre?>(genre),
                  isbn: Nullable<String?>((isbn?.isEmpty ?? true) ? null : isbn),
                  publishedDate: Nullable<DateTime?>(publishedDate),
                  noOfPages: Nullable<int?>(noOfPages),
                  originalTitle: Nullable<String?>(
                    (originalTitle?.isEmpty ?? true) ? null : originalTitle,
                  ),
                  originalLanguage: Nullable<OriginalLanguage?>(originalLanguage),
                  collectionStatus: Nullable<CollectionStatus?>(collectionStatus),
                  collectedDate: Nullable<DateTime?>(collectedDate),
                  lendedDate: Nullable<DateTime?>(lendedDate),
                  dueDate: Nullable<DateTime?>(dueDate),
                  readingStatus: Nullable<ReadingStatus?>(readingStatus),
                  pausedPage: Nullable<int?>(pausedPage),
                  completedDate: Nullable<DateTime?>(completedDate),
                  notes: Nullable<String?>((notes?.isEmpty ?? true) ? null : notes),
                  authorIds: authorIds,
                  translatorIds: translatorIds,
                  workIds: workIds,
                  sequenceVolumeIds: sequenceVolumeIds,
                  publisherId: Nullable<String?>(publisherId),
                  readerId: Nullable<String?>(readerId),
                  lastUpdated: DateTime.now(),
                )
              : BookEntity(
                  id: bookId,
                  title: title,
                  compilationType: compilationType,
                  isTranslation: isTranslation,
                  cover: state.pickedBase64Image,
                  language: language,
                  genre: genre,
                  isbn: isbn,
                  publishedDate: publishedDate,
                  noOfPages: noOfPages,
                  originalTitle: isTranslation ? originalTitle : null,
                  originalLanguage: isTranslation ? originalLanguage : null,
                  collectionStatus: collectionStatus,
                  collectedDate: collectedDate,
                  lendedDate: lendedDate,
                  dueDate: dueDate,
                  readingStatus: readingStatus,
                  pausedPage: pausedPage,
                  completedDate: completedDate,
                  notes: notes,
                  authorIds: authorIds,
                  translatorIds: translatorIds,
                  workIds: workIds,
                  sequenceVolumeIds: sequenceVolumeIds,
                  publisherId: publisherId,
                  readerId: readerId,
                  createdDate: DateTime.now(),
                  lastUpdated: DateTime.now(),
                );

      if (existingBook != null) {
        await ref.read(editBookUseCaseProvider)(bookToSave);
      } else {
        await ref.read(addBookUseCaseProvider)(bookToSave);
      }

      state = state.copyWith(isLoading: false);

      return bookToSave;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>(e.message));
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>('Error saving book: $e'));
      return null;
    }
  }
}
