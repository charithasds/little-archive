import '../../../sequence/domain/entities/sequence_entity.dart';
import '../entities/work_entity.dart';
import '../repositories/work_repository.dart';

class GenerateWorkIdUseCase {
  const GenerateWorkIdUseCase(this.repository);
  final WorkRepository repository;

  String call() => repository.generateId();
}

class FetchWorksUseCase {
  const FetchWorksUseCase(this.repository);
  final WorkRepository repository;

  Future<List<WorkEntity>> call() => repository.fetchWorks();
}

class FetchWorkByIdUseCase {
  const FetchWorkByIdUseCase(this.repository);
  final WorkRepository repository;

  Future<WorkEntity?> call(String id) => repository.fetchWorkById(id);
}

class WatchWorksUseCase {
  const WatchWorksUseCase(this.repository);
  final WorkRepository repository;

  Stream<List<WorkEntity>> call() => repository.watchWorks();
}

class AddWorkUseCase {
  const AddWorkUseCase(this.repository);
  final WorkRepository repository;

  Future<void> call(WorkEntity work) => repository.addWork(work);
}

class EditWorkUseCase {
  const EditWorkUseCase(this.repository);
  final WorkRepository repository;

  Future<void> call(WorkEntity work, {WorkEntity? oldWork}) =>
      repository.editWork(work, oldWork: oldWork);
}

class RemoveWorkUseCase {
  const RemoveWorkUseCase(this.repository);
  final WorkRepository repository;

  Future<void> call(String id) => repository.removeWork(id);
}

class UpsertWorkUseCase {
  const UpsertWorkUseCase(this.repository);
  final WorkRepository repository;

  Future<WorkEntity> call({
    required WorkEntity work,
    required Map<SequenceEntity, String> sequenceEntries,
    required bool isEdit,
    bool applyToBooks = false,
  }) => repository.upsertWork(
    work,
    sequenceEntries.map((SequenceEntity k, String v) => MapEntry<String, String>(k.id, v)),
    isEdit,
    applyToBooks,
  );
}
