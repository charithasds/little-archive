import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repositories/creator_repository_impl.dart';
import '../domain/usecases/creator_usecases.dart';

export '../domain/usecases/creator_usecases.dart';

part 'creator_usecase_providers.g.dart';

@riverpod
GenerateCreatorIdUseCase generateCreatorIdUseCase(Ref ref) =>
    GenerateCreatorIdUseCase(ref.watch(creatorRepositoryProvider));

@riverpod
FetchCreatorsUseCase fetchCreatorsUseCase(Ref ref) =>
    FetchCreatorsUseCase(ref.watch(creatorRepositoryProvider));

@riverpod
FetchCreatorByIdUseCase fetchCreatorByIdUseCase(Ref ref) =>
    FetchCreatorByIdUseCase(ref.watch(creatorRepositoryProvider));

@riverpod
WatchCreatorsUseCase watchCreatorsUseCase(Ref ref) =>
    WatchCreatorsUseCase(ref.watch(creatorRepositoryProvider));

@riverpod
AddCreatorUseCase addCreatorUseCase(Ref ref) =>
    AddCreatorUseCase(ref.watch(creatorRepositoryProvider));

@riverpod
EditCreatorUseCase editCreatorUseCase(Ref ref) =>
    EditCreatorUseCase(ref.watch(creatorRepositoryProvider));

@riverpod
RemoveCreatorUseCase removeCreatorUseCase(Ref ref) =>
    RemoveCreatorUseCase(ref.watch(creatorRepositoryProvider));

@riverpod
MergeCreatorsUseCase mergeCreatorsUseCase(Ref ref) =>
    MergeCreatorsUseCase(ref.watch(creatorRepositoryProvider));
