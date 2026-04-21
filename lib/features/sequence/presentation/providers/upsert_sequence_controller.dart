import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/domain/entities/user_entity.dart';
import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/domain/error/exceptions.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../domain/entities/sequence_entity.dart';
import 'sequence_provider.dart';

class UpsertSequenceState {
  const UpsertSequenceState({this.isLoading = false, this.error});

  final bool isLoading;
  final String? error;

  UpsertSequenceState copyWith({bool? isLoading, String? error}) =>
      UpsertSequenceState(isLoading: isLoading ?? this.isLoading, error: error);
}

class UpsertSequenceController extends Notifier<UpsertSequenceState> {
  @override
  UpsertSequenceState build() => const UpsertSequenceState();

  Future<SequenceEntity?> saveSequence({
    required SequenceEntity? existingSequence,
    required String name,
    String? otherName,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true);

    final UserEntity? user = ref.read(authStateProvider).value;

    if (user == null) {
      state = state.copyWith(isLoading: false, error: 'User not authenticated');
      return null;
    }

    final String generatedId = ref.read(sequenceRepositoryProvider).generateId();

    final SequenceEntity sequenceToSave = existingSequence != null
        ? existingSequence.copyWith(
            name: name,
            otherName: Nullable<String?>(otherName?.isEmpty ?? true ? null : otherName),
            notes: Nullable<String?>(notes?.isEmpty ?? true ? null : notes),
            lastUpdated: DateTime.now(),
          )
        : SequenceEntity(
            id: generatedId,
            name: name,
            otherName: otherName?.isEmpty ?? true ? null : otherName,
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

      return sequenceToSave;
    } on NoConnectionException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error saving sequence: $e');
      return null;
    }
  }
}

final NotifierProvider<UpsertSequenceController, UpsertSequenceState>
upsertSequenceControllerProvider = NotifierProvider<UpsertSequenceController, UpsertSequenceState>(
  UpsertSequenceController.new,
);
