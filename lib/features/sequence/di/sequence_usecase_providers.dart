import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repositories/sequence_repository_impl.dart';
import '../domain/usecases/sequence_usecases.dart';

export '../domain/usecases/sequence_usecases.dart';

part 'sequence_usecase_providers.g.dart';

@riverpod
GenerateSequenceIdUseCase generateSequenceIdUseCase(Ref ref) =>
    GenerateSequenceIdUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
FetchSequencesUseCase fetchSequencesUseCase(Ref ref) =>
    FetchSequencesUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
FetchSequenceByIdUseCase fetchSequenceByIdUseCase(Ref ref) =>
    FetchSequenceByIdUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
WatchSequencesUseCase watchSequencesUseCase(Ref ref) =>
    WatchSequencesUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
AddSequenceUseCase addSequenceUseCase(Ref ref) =>
    AddSequenceUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
EditSequenceUseCase editSequenceUseCase(Ref ref) =>
    EditSequenceUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
RemoveSequenceUseCase removeSequenceUseCase(Ref ref) =>
    RemoveSequenceUseCase(ref.watch(sequenceRepositoryProvider));
