import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../domain/entities/sequence_entity.dart';
import '../../domain/usecases/sequence_usecases.dart';
import 'sequence_provider.dart';

part 'upsert_sequence_controller.g.dart';

class UpsertSequenceState {
  const UpsertSequenceState({this.existingSequence, this.isLoading = false, this.error});

  final SequenceEntity? existingSequence;
  final bool isLoading;
  final String? error;

  UpsertSequenceState copyWith({
    Nullable<SequenceEntity?>? existingSequence,
    bool? isLoading,
    Nullable<String?>? error,
  }) => UpsertSequenceState(
    existingSequence: existingSequence != null ? existingSequence.value : this.existingSequence,
    isLoading: isLoading ?? this.isLoading,
    error: error != null ? error.value : this.error,
  );
}

@riverpod
class UpsertSequenceController extends _$UpsertSequenceController {
  @override
  UpsertSequenceState build() => const UpsertSequenceState();

  void initializeWith(SequenceEntity? sequence) {
    state = UpsertSequenceState(existingSequence: sequence);
  }

  Future<SequenceEntity?> saveSequence({required String name, String? notes}) async {
    state = state.copyWith(isLoading: true, error: const Nullable<String?>(null));



    final SequenceEntity? existingSequence = state.existingSequence;
    final String generatedId = ref.read(generateSequenceIdUseCaseProvider)();

    final SequenceEntity sequenceToSave = existingSequence != null
        ? existingSequence.copyWith(
            name: name,
            notes: Nullable<String?>(notes?.isEmpty ?? true ? null : notes),
            lastUpdated: DateTime.now(),
          )
        : SequenceEntity(
            id: generatedId,
            name: name,
            notes: notes?.isEmpty ?? true ? null : notes,
            sequenceVolumeIds: const <String>[],
            createdDate: DateTime.now(),
            lastUpdated: DateTime.now(),
          );

    try {
      if (existingSequence != null) {
        await ref.read(editSequenceUseCaseProvider)(sequenceToSave);
      } else {
        await ref.read(addSequenceUseCaseProvider)(sequenceToSave);
      }

      state = state.copyWith(isLoading: false);
      ref.invalidate(sequenceCountProvider);
      return sequenceToSave;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: Nullable<String?>(e.message));
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: Nullable<String?>('Error saving sequence: $e'),
      );
      return null;
    }
  }
}
