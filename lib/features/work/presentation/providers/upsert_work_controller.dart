import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../../../core/shared/domain/enums/content_category.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/usecases/work_usecases.dart';
import 'work_provider.dart';

part 'upsert_work_controller.g.dart';

class UpsertWorkState {
  const UpsertWorkState({this.existingWork, this.isLoading = false, this.error});

  final WorkEntity? existingWork;
  final bool isLoading;
  final String? error;

  UpsertWorkState copyWith({
    Nullable<WorkEntity?>? existingWork,
    bool? isLoading,
    Nullable<String?>? error,
  }) => UpsertWorkState(
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
    bool toBeTranslated = false,
    Language? language,
    Genre? genre,
    String? originalTitle,
    OriginalLanguage? originalLanguage,
    String? notes,
    List<String> authorIds = const <String>[],
    List<String> translatorIds = const <String>[],
    Map<SequenceEntity, String> sequenceEntries = const <SequenceEntity, String>{},
    String? bookId,
  }) async {
    state = state.copyWith(isLoading: true, error: const Nullable<String?>(null));



    try {
      final WorkEntity? existingWork = state.existingWork;
      final String workId = existingWork?.id ?? ref.read(generateWorkIdUseCaseProvider)();
      final WorkEntity workToSave = existingWork != null
          ? existingWork.copyWith(
              title: title,
              contentCategory: contentCategory,
              isTranslation: isTranslation,
              toBeTranslated: toBeTranslated,
              language: Nullable<Language?>(language),
              genre: Nullable<Genre?>(genre),
              originalTitle: Nullable<String?>(
                originalTitle?.isEmpty ?? true ? null : originalTitle,
              ),
              originalLanguage: Nullable<OriginalLanguage?>(originalLanguage),
              notes: Nullable<String?>(notes?.isEmpty ?? true ? null : notes),
              authorIds: authorIds,
              translatorIds: translatorIds,
              sequenceVolumeIds: <String>[],
              bookId: Nullable<String?>(bookId),
              lastUpdated: DateTime.now(),
            )
          : WorkEntity(
              id: workId,
              title: title,
              contentCategory: contentCategory,
              isTranslation: isTranslation,
              toBeTranslated: toBeTranslated,
              language: language,
              genre: genre,
              originalTitle: isTranslation ? originalTitle : null,
              originalLanguage: isTranslation ? originalLanguage : null,
              notes: notes,
              authorIds: authorIds,
              translatorIds: translatorIds,
              sequenceVolumeIds: const <String>[],
              bookId: bookId,
              createdDate: DateTime.now(),
              lastUpdated: DateTime.now(),
            );

      final WorkEntity savedWork = await ref.read(upsertWorkUseCaseProvider)(
        work: workToSave,
        sequenceEntries: sequenceEntries,
        isEdit: existingWork != null,
      );

      state = state.copyWith(isLoading: false);
      ref.invalidate(workCountProvider);
      return savedWork;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>(e.message));
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>('Error saving work: $e'));
      return null;
    }
  }
}
