import '../entities/creator_entity.dart';
import '../repositories/creator_repository.dart';

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
