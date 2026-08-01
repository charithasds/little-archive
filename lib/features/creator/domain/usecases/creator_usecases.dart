import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/creator_repository_impl.dart';
import '../entities/creator_entity.dart';
import '../repositories/creator_repository.dart';

part 'creator_usecases.g.dart';

class GenerateCreatorIdUseCase {
  const GenerateCreatorIdUseCase(this.repository);
  final CreatorRepository repository;

  String call() => repository.generateId();
}

class FetchCreatorsUseCase {
  const FetchCreatorsUseCase(this.repository);
  final CreatorRepository repository;

  Future<List<CreatorEntity>> call() => repository.fetchCreators();
}

class FetchCreatorByIdUseCase {
  const FetchCreatorByIdUseCase(this.repository);
  final CreatorRepository repository;

  Future<CreatorEntity?> call(String id) => repository.fetchCreatorById(id);
}

class WatchCreatorsUseCase {
  const WatchCreatorsUseCase(this.repository);
  final CreatorRepository repository;

  Stream<List<CreatorEntity>> call() => repository.watchCreators();
}

class AddCreatorUseCase {
  const AddCreatorUseCase(this.repository);
  final CreatorRepository repository;

  Future<void> call(CreatorEntity creator) => repository.addCreator(creator);
}

class EditCreatorUseCase {
  const EditCreatorUseCase(this.repository);
  final CreatorRepository repository;

  Future<void> call(CreatorEntity creator, {CreatorEntity? oldCreator}) =>
      repository.editCreator(creator, oldCreator: oldCreator);
}

class RemoveCreatorUseCase {
  const RemoveCreatorUseCase(this.repository);
  final CreatorRepository repository;

  Future<void> call(String id) => repository.removeCreator(id);
}

class MergeCreatorsUseCase {
  const MergeCreatorsUseCase(this.repository);
  final CreatorRepository repository;

  Future<void> call(String targetId, String sourceId) => repository.mergeCreators(targetId, sourceId);
}

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
AddCreatorUseCase addCreatorUseCase(Ref ref) => AddCreatorUseCase(ref.watch(creatorRepositoryProvider));

@riverpod
EditCreatorUseCase editCreatorUseCase(Ref ref) =>
    EditCreatorUseCase(ref.watch(creatorRepositoryProvider));

@riverpod
RemoveCreatorUseCase removeCreatorUseCase(Ref ref) =>
    RemoveCreatorUseCase(ref.watch(creatorRepositoryProvider));

@riverpod
MergeCreatorsUseCase mergeCreatorsUseCase(Ref ref) =>
    MergeCreatorsUseCase(ref.watch(creatorRepositoryProvider));
