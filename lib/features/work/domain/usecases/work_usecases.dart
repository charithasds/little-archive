import '../entities/work_entity.dart';
import '../repositories/work_repository.dart';

class GetWorksUseCase {
  const GetWorksUseCase(this.repository);
  final WorkRepository repository;

  Future<List<WorkEntity>> call(String userId) => repository.getWorks(userId);
}

class WatchWorksUseCase {
  const WatchWorksUseCase(this.repository);
  final WorkRepository repository;

  Stream<List<WorkEntity>> call(String userId) => repository.watchWorks(userId);
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

class UpdateWorkUseCase {
  const UpdateWorkUseCase(this.repository);
  final WorkRepository repository;

  Future<void> call(WorkEntity work) => repository.updateWork(work);
}

class DeleteWorkUseCase {
  const DeleteWorkUseCase(this.repository);
  final WorkRepository repository;

  Future<void> call(String id) => repository.deleteWork(id);
}
