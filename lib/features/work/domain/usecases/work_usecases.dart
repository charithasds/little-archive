import '../entities/work_entity.dart';
import '../repositories/work_repository.dart';

class GetWorksUseCase {
  const GetWorksUseCase(this.repository);
  final WorkRepository repository;

  Future<List<WorkEntity>> call() => repository.getWorks();
}

class WatchWorksUseCase {
  const WatchWorksUseCase(this.repository);
  final WorkRepository repository;

  Stream<List<WorkEntity>> call() => repository.watchWorks();
}

class GetWorkByIdUseCase {
  const GetWorkByIdUseCase(this.repository);
  final WorkRepository repository;

  Future<WorkEntity?> call(String id) => repository.getWorkById(id);
}

class AddWorkUseCase {
  const AddWorkUseCase(this.repository);
  final WorkRepository repository;

  Future<void> call(WorkEntity work) => repository.addWork(work);
}

class EditWorkUseCase {
  const EditWorkUseCase(this.repository);
  final WorkRepository repository;

  Future<void> call(WorkEntity work) => repository.editWork(work);
}

class RemoveWorkUseCase {
  const RemoveWorkUseCase(this.repository);
  final WorkRepository repository;

  Future<void> call(String id) => repository.removeWork(id);
}
