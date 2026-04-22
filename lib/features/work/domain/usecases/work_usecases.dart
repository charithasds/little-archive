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

  Future<void> call(WorkEntity work) => repository.editWork(work);
}

class RemoveWorkUseCase {
  const RemoveWorkUseCase(this.repository);
  final WorkRepository repository;

  Future<void> call(String id) => repository.removeWork(id);
}
