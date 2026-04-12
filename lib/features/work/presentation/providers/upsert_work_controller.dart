import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/enums/content_category.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/entities/sequence_volume_entity.dart';
import '../../../sequence/presentation/providers/sequence_provider.dart';
import '../../domain/entities/work_entity.dart';
import 'work_provider.dart';

class UpsertWorkState {
  const UpsertWorkState({this.isLoading = false, this.error});

  final bool isLoading;
  final String? error;

  UpsertWorkState copyWith({bool? isLoading, String? error}) =>
      UpsertWorkState(isLoading: isLoading ?? this.isLoading, error: error);
}

class UpsertWorkController extends Notifier<UpsertWorkState> {
  @override
  UpsertWorkState build() => const UpsertWorkState();

  Future<WorkEntity?> saveWork({
    required WorkEntity? existingWork,
    required String title,
    required Language? language,
    required Genre? genre,
    required ContentCategory contentCategory,
    required int? noOfPages,
    required bool isTranslation,
    required String? originalTitle,
    required OriginalLanguage? originalLanguage,
    required ReadingStatus readingStatus,
    required int? pausedPage,
    required DateTime? completedDate,
    required String? notes,
    required List<String> authorIds,
    required List<String> translatorIds,
    required Map<SequenceEntity, String> selectedSequences,
    required String? bookId,
  }) async {
    state = state.copyWith(isLoading: true);

    final UserEntity? user = ref.read(authStateProvider).value;

    if (user == null) {
      state = state.copyWith(isLoading: false, error: 'User not authenticated');
      return null;
    }

    try {
      final String workId = existingWork?.id ?? ref.read(workRepositoryProvider).generateId();
      final List<String> sequenceVolumeIds = <String>[];

      if (existingWork != null) {
        final List<SequenceVolumeEntity> oldVolumes = await ref
            .read(sequenceRepositoryProvider)
            .getSequenceVolumesByWorkId(workId, user.uid);

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
          workId: workId,
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

      final WorkEntity workToSave = existingWork != null
          ? existingWork.copyWith(
              title: title,
              language: language,
              genre: genre,
              contentCategory: contentCategory,
              noOfPages: noOfPages,
              isTranslation: isTranslation,
              originalTitle: isTranslation ? originalTitle : null,
              originalLanguage: isTranslation ? originalLanguage : null,
              readingStatus: readingStatus,
              pausedPage: pausedPage,
              completedDate: completedDate,
              notes: notes,
              lastUpdated: DateTime.now(),
              authorIds: authorIds,
              translatorIds: translatorIds,
              sequenceVolumeIds: sequenceVolumeIds,
              bookId: bookId,
            )
          : WorkEntity(
              id: workId,
              title: title,
              language: language,
              genre: genre,
              contentCategory: contentCategory,
              noOfPages: noOfPages,
              isTranslation: isTranslation,
              originalTitle: isTranslation ? originalTitle : null,
              originalLanguage: isTranslation ? originalLanguage : null,
              readingStatus: readingStatus,
              pausedPage: pausedPage,
              completedDate: completedDate,
              notes: notes,
              createdDate: DateTime.now(),
              lastUpdated: DateTime.now(),
              authorIds: authorIds,
              translatorIds: translatorIds,
              sequenceVolumeIds: sequenceVolumeIds,
              bookId: bookId,
            );

      if (existingWork != null) {
        await ref.read(updateWorkUseCaseProvider)(workToSave);
      } else {
        await ref.read(addWorkUseCaseProvider)(workToSave);
      }

      state = state.copyWith(isLoading: false);

      return workToSave;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error saving work: $e');
      return null;
    }
  }
}

final NotifierProvider<UpsertWorkController, UpsertWorkState> upsertWorkControllerProvider =
    NotifierProvider<UpsertWorkController, UpsertWorkState>(UpsertWorkController.new);
