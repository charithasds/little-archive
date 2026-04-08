import '../../../../core/shared/domain/usecases/usecase.dart';
import '../../domain/entities/work_entity.dart';
import '../../domain/repositories/work_repository.dart';

class GetWorksUseCase implements UseCase<List<WorkEntity>, String> {
  GetWorksUseCase(this.repository);
  final WorkRepository repository;

  @override
  Future<List<WorkEntity>> call(String params) => repository.getWorks(params);
}

class WatchWorksUseCase implements UseCase<Stream<List<WorkEntity>>, String> {
  WatchWorksUseCase(this.repository);
  final WorkRepository repository;

  @override
  Future<Stream<List<WorkEntity>>> call(String params) async => repository.watchWorks(params);
}

class GetWorkByIdUseCase implements UseCase<WorkEntity?, String> {
  GetWorkByIdUseCase(this.repository);
  final WorkRepository repository;

  @override
  Future<WorkEntity?> call(String params) => repository.getWorkById(params);
}

class AddWorkUseCase implements UseCase<void, WorkEntity> {
  AddWorkUseCase(this.repository);
  final WorkRepository repository;

  @override
  Future<void> call(WorkEntity params) => repository.addWork(params);
}

class UpdateWorkUseCase implements UseCase<void, WorkEntity> {
  UpdateWorkUseCase(this.repository);
  final WorkRepository repository;

  @override
  Future<void> call(WorkEntity params) => repository.updateWork(params);
}

class DeleteWorkUseCase implements UseCase<void, String> {
  DeleteWorkUseCase(this.repository);
  final WorkRepository repository;

  @override
  Future<void> call(String params) => repository.deleteWork(params);
}
