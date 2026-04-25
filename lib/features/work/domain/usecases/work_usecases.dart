import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../sequence/domain/entities/sequence_entity.dart';
import '../../../sequence/domain/usecases/sequence_usecases.dart';
import '../../data/repositories/work_repository_impl.dart';
import '../entities/work_entity.dart';
import '../repositories/work_repository.dart';

part 'work_usecases.g.dart';

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

class UpsertWorkUseCase {
  const UpsertWorkUseCase({
    required this.workRepository,
    required this.syncSequenceVolumesUseCase,
  });

  final WorkRepository workRepository;
  final SyncWorkSequenceVolumesUseCase syncSequenceVolumesUseCase;

  Future<WorkEntity> call({
    required WorkEntity work,
    required Map<SequenceEntity, String> sequenceEntries,
    required bool isEdit,
  }) async {
    final List<String> sequenceVolumeIds = await syncSequenceVolumesUseCase(
      workId: work.id,
      entries: sequenceEntries,
      isEdit: isEdit,
    );

    final WorkEntity workToSave = work.copyWith(sequenceVolumeIds: sequenceVolumeIds);

    if (isEdit) {
      await workRepository.editWork(workToSave);
    } else {
      await workRepository.addWork(workToSave);
    }

    return workToSave;
  }
}

@riverpod
GenerateWorkIdUseCase generateWorkIdUseCase(Ref ref) =>
    GenerateWorkIdUseCase(ref.watch(workRepositoryProvider));

@riverpod
FetchWorksUseCase fetchWorksUseCase(Ref ref) =>
    FetchWorksUseCase(ref.watch(workRepositoryProvider));

@riverpod
FetchWorkByIdUseCase fetchWorkByIdUseCase(Ref ref) =>
    FetchWorkByIdUseCase(ref.watch(workRepositoryProvider));

@riverpod
WatchWorksUseCase watchWorksUseCase(Ref ref) =>
    WatchWorksUseCase(ref.watch(workRepositoryProvider));

@riverpod
AddWorkUseCase addWorkUseCase(Ref ref) => AddWorkUseCase(ref.watch(workRepositoryProvider));

@riverpod
EditWorkUseCase editWorkUseCase(Ref ref) => EditWorkUseCase(ref.watch(workRepositoryProvider));

@riverpod
RemoveWorkUseCase removeWorkUseCase(Ref ref) =>
    RemoveWorkUseCase(ref.watch(workRepositoryProvider));

@riverpod
UpsertWorkUseCase upsertWorkUseCase(Ref ref) => UpsertWorkUseCase(
  workRepository: ref.watch(workRepositoryProvider),
  syncSequenceVolumesUseCase: ref.watch(syncWorkSequenceVolumesUseCaseProvider),
);
