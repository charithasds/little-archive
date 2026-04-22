import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/enums/content_category.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/presentation/providers/book_provider.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../domain/entities/work_entity.dart';
import 'work_provider.dart';

part 'upsert_work_controller.g.dart';

class UpsertWorkState {
  const UpsertWorkState({
    this.existingWork,
    this.isLoading = false,
    this.error,
  });

  final WorkEntity? existingWork;
  final bool isLoading;
  final String? error;

  UpsertWorkState copyWith({
    Nullable<WorkEntity?>? existingWork,
    bool? isLoading,
    Nullable<String?>? error,
  }) =>
      UpsertWorkState(
        existingWork: existingWork != null ? existingWork.value : this.existingWork,
        isLoading: isLoading ?? this.isLoading,
        error: error != null ? error.value : this.error,
      );
}

@riverpod
class UpsertWorkController extends _$UpsertWorkController {
  @override
  UpsertWorkState build() => const UpsertWorkState();

  void initializeWith(WorkEntity? work) {
    state = UpsertWorkState(existingWork: work);
  }

  Future<WorkEntity?> saveWork({
    required String title,
    required ContentCategory contentCategory,
    required bool isTranslation,
    Language? language,
    Genre? genre,
    int? noOfPages,
    String? originalTitle,
    OriginalLanguage? originalLanguage,
    String? notes,
    List<String> authorIds = const <String>[],
    List<String> translatorIds = const <String>[],
    Map<SequenceEntity, String> sequenceEntries = const <SequenceEntity, String>{},
    String? bookId,
  }) async {
    state = state.copyWith(isLoading: true, error: const Nullable<String?>(null));

    final UserEntity? user = ref.read(authStateProvider).value;

    if (user == null) {
      state = state.copyWith(isLoading: false, error: const Nullable<String?>('User not authenticated'));
      return null;
    }

    try {
      final WorkEntity? existingWork = state.existingWork;
      final String workId = existingWork?.id ?? ref.read(generateWorkIdUseCaseProvider)();
      final List<String> sequenceVolumeIds = <String>[];

      if (existingWork != null) {
        final List<SequenceVolumeEntity> oldVolumes =
            await ref.read(fetchSequenceVolumesByWorkIdUseCaseProvider)(workId);

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
          workId: workId,
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

      final WorkEntity workToSave =
          existingWork != null
              ? existingWork.copyWith(
                  title: title,
                  contentCategory: contentCategory,
                  isTranslation: isTranslation,
                  language: Nullable<Language?>(language),
                  genre: Nullable<Genre?>(genre),
                  noOfPages: Nullable<int?>(noOfPages),
                  originalTitle: Nullable<String?>(
                    originalTitle?.isEmpty ?? true ? null : originalTitle,
                  ),
                  originalLanguage: Nullable<OriginalLanguage?>(originalLanguage),
                  notes: Nullable<String?>(notes?.isEmpty ?? true ? null : notes),
                  authorIds: authorIds,
                  translatorIds: translatorIds,
                  sequenceVolumeIds: sequenceVolumeIds,
                  bookId: Nullable<String?>(bookId),
                  lastUpdated: DateTime.now(),
                )
              : WorkEntity(
                  id: workId,
                  title: title,
                  contentCategory: contentCategory,
                  isTranslation: isTranslation,
                  language: language,
                  genre: genre,
                  noOfPages: noOfPages,
                  originalTitle: isTranslation ? originalTitle : null,
                  originalLanguage: isTranslation ? originalLanguage : null,
                  notes: notes,
                  authorIds: authorIds,
                  translatorIds: translatorIds,
                  sequenceVolumeIds: sequenceVolumeIds,
                  bookId: bookId,
                  createdDate: DateTime.now(),
                  lastUpdated: DateTime.now(),
                );

      if (existingWork != null) {
        await ref.read(editWorkUseCaseProvider)(workToSave);
      } else {
        await ref.read(addWorkUseCaseProvider)(workToSave);
      }

      // Keep Book.workIds in sync with this work's bookId.
      await _syncBookWorkIds(workId: workId, oldBookId: existingWork?.bookId, newBookId: bookId);

      state = state.copyWith(isLoading: false);

      return workToSave;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>(e.message));
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>('Error saving work: $e'));
      return null;
    }
  }

  /// Keeps [BookEntity.workIds] consistent when this work's [bookId] changes.
  ///
  /// - [oldBookId]: the bookId the work *previously* pointed to (null for new works).
  /// - [newBookId]: the bookId the work *now* points to (null if unlinked).
  Future<void> _syncBookWorkIds({
    required String workId,
    required String? oldBookId,
    required String? newBookId,
  }) async {
    final bool bookUnchanged = oldBookId == newBookId;
    if (bookUnchanged) {
      return;
    }

    // Remove workId from the old book's workIds.
    if (oldBookId != null) {
      final BookEntity? oldBook = await ref.read(fetchBookByIdUseCaseProvider)(oldBookId);
      if (oldBook != null) {
        final List<String> updated = List<String>.from(oldBook.workIds)..remove(workId);
        await ref.read(editBookUseCaseProvider)(oldBook.copyWith(workIds: updated));
      }
    }

    // Add workId to the new book's workIds.
    if (newBookId != null) {
      final BookEntity? newBook = await ref.read(fetchBookByIdUseCaseProvider)(newBookId);
      if (newBook != null && !newBook.workIds.contains(workId)) {
        final List<String> updated = List<String>.from(newBook.workIds)..add(workId);
        await ref.read(editBookUseCaseProvider)(newBook.copyWith(workIds: updated));
      }
    }
  }
}
