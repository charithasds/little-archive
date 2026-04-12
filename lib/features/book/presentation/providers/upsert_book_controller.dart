import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../domain/entities/book_entity.dart';
import 'book_provider.dart';

class UpsertBookState {
  const UpsertBookState({this.isLoading = false, this.error, this.pickedBase64Image});

  final bool isLoading;
  final String? error;
  final String? pickedBase64Image;

  UpsertBookState copyWith({
    bool? isLoading,
    String? error,
    String? pickedBase64Image,
    bool clearImage = false,
  }) => UpsertBookState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    pickedBase64Image: clearImage ? null : (pickedBase64Image ?? this.pickedBase64Image),
  );
}

class UpsertBookController extends Notifier<UpsertBookState> {
  @override
  UpsertBookState build() => const UpsertBookState();

  void initializeWith(BookEntity? book) {
    if (book != null && book.cover != null) {
      state = state.copyWith(pickedBase64Image: book.cover);
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      state = state.copyWith(pickedBase64Image: base64Encode(bytes));
    }
  }

  Future<BookEntity?> saveBook({
    required BookEntity? existingBook,
    required String title,
    required CompilationType compilationType,
    required Language? language,
    required Genre? genre,
    required String? isbn,
    required DateTime? publishedDate,
    required int? noOfPages,
    required bool isTranslation,
    required String? originalTitle,
    required OriginalLanguage? originalLanguage,
    required CollectionStatus collectionStatus,
    required DateTime? collectedDate,
    required DateTime? lendedDate,
    required DateTime? dueDate,
    required ReadingStatus readingStatus,
    required int? pausedPage,
    required DateTime? completedDate,
    required String? notes,
    required List<String> authorIds,
    required List<String> translatorIds,
    required List<String> workIds,
    required Map<SequenceEntity, String> selectedSequences,
    required String? publisherId,
    required String? readerId,
  }) async {
    state = state.copyWith(isLoading: true);

    final UserEntity? user = ref.read(authStateProvider).value;

    if (user == null) {
      state = state.copyWith(isLoading: false, error: 'User not authenticated');
      return null;
    }

    try {
      final String bookId = existingBook?.id ?? ref.read(bookRepositoryProvider).generateId();
      final List<String> sequenceVolumeIds = <String>[];

      if (existingBook != null) {
        final List<SequenceVolumeEntity> oldVolumes = await ref
            .read(sequenceRepositoryProvider)
            .getSequenceVolumesByBookId(bookId, user.uid);

        for (final SequenceVolumeEntity vol in oldVolumes) {
          await ref.read(sequenceRepositoryProvider).deleteSequenceVolume(vol.id);

          final SequenceEntity? seq = await ref
              .read(sequenceRepositoryProvider)
              .getSequenceById(vol.sequenceId);

          if (seq != null) {
            final List<String> newIds = List<String>.from(seq.sequenceVolumeIds)..remove(vol.id);
            await ref
                .read(sequenceRepositoryProvider)
                .updateSequence(seq.copyWith(sequenceVolumeIds: newIds));
          }
        }
      }

      for (final MapEntry<SequenceEntity, String> entry in selectedSequences.entries) {
        final SequenceEntity sequence = entry.key;
        final String volumeNumber = entry.value;

        final String volumeId = ref.read(sequenceRepositoryProvider).generateVolumeId();
        final SequenceVolumeEntity volume = SequenceVolumeEntity(
          id: volumeId,
          volume: volumeNumber,
          sequenceId: sequence.id,
          bookId: bookId,
          createdDate: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        await ref.read(sequenceRepositoryProvider).addSequenceVolume(volume);

        final SequenceEntity? currentSequence = await ref
            .read(sequenceRepositoryProvider)
            .getSequenceById(sequence.id);

        if (currentSequence != null) {
          final SequenceEntity updatedSequence = currentSequence.copyWith(
            sequenceVolumeIds: <String>[...currentSequence.sequenceVolumeIds, volumeId],
          );
          await ref.read(sequenceRepositoryProvider).updateSequence(updatedSequence);
        }

        sequenceVolumeIds.add(volumeId);
      }

      final BookEntity bookToSave = existingBook != null
          ? existingBook.copyWith(
              title: title,
              cover: state.pickedBase64Image,
              compilationType: compilationType,
              language: language,
              genre: genre,
              isbn: isbn,
              publishedDate: publishedDate,
              noOfPages: noOfPages,
              isTranslation: isTranslation,
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
              lastUpdated: DateTime.now(),
              authorIds: authorIds,
              translatorIds: translatorIds,
              workIds: workIds,
              sequenceVolumeIds: sequenceVolumeIds,
              publisherId: publisherId,
              readerId: readerId,
            )
          : BookEntity(
              id: bookId,
              title: title,
              cover: state.pickedBase64Image,
              compilationType: compilationType,
              language: language,
              genre: genre,
              isbn: isbn,
              publishedDate: publishedDate,
              noOfPages: noOfPages,
              isTranslation: isTranslation,
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
              createdDate: DateTime.now(),
              lastUpdated: DateTime.now(),
              authorIds: authorIds,
              translatorIds: translatorIds,
              workIds: workIds,
              sequenceVolumeIds: sequenceVolumeIds,
              publisherId: publisherId,
              readerId: readerId,
            );

      if (existingBook != null) {
        await ref.read(updateBookUseCaseProvider)(bookToSave);
      } else {
        await ref.read(addBookUseCaseProvider)(bookToSave);
      }

      state = state.copyWith(isLoading: false);

      return bookToSave;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error saving book: $e');
      return null;
    }
  }
}

final NotifierProvider<UpsertBookController, UpsertBookState> upsertBookControllerProvider =
    NotifierProvider<UpsertBookController, UpsertBookState>(UpsertBookController.new);
