import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/sequence_repository_impl.dart';
import '../entities/sequence_entity.dart';
import '../entities/sequence_volume_entity.dart';
import '../repositories/sequence_repository.dart';

part 'sequence_usecases.g.dart';

class GenerateSequenceIdUseCase {
  const GenerateSequenceIdUseCase(this.repository);
  final SequenceRepository repository;

  String call() => repository.generateId();
}

class FetchSequencesUseCase {
  const FetchSequencesUseCase(this.repository);
  final SequenceRepository repository;

  Future<List<SequenceEntity>> call() => repository.fetchSequences();
}

class FetchSequenceByIdUseCase {
  const FetchSequenceByIdUseCase(this.repository);
  final SequenceRepository repository;

  Future<SequenceEntity?> call(String id) => repository.fetchSequenceById(id);
}

class WatchSequencesUseCase {
  const WatchSequencesUseCase(this.repository);
  final SequenceRepository repository;

  Stream<List<SequenceEntity>> call() => repository.watchSequences();
}

class FetchSequenceCountUseCase {
  const FetchSequenceCountUseCase(this.repository);
  final SequenceRepository repository;

  Future<int> call() => repository.fetchCount();
}

class AddSequenceUseCase {
  const AddSequenceUseCase(this.repository);
  final SequenceRepository repository;

  Future<void> call(SequenceEntity sequence) => repository.addSequence(sequence);
}

class EditSequenceUseCase {
  const EditSequenceUseCase(this.repository);
  final SequenceRepository repository;

  Future<void> call(SequenceEntity sequence) => repository.editSequence(sequence);
}

class RemoveSequenceUseCase {
  const RemoveSequenceUseCase(this.repository);
  final SequenceRepository repository;

  Future<void> call(String id) => repository.removeSequence(id);
}

class GenerateSequenceVolumeIdUseCase {
  const GenerateSequenceVolumeIdUseCase(this.repository);
  final SequenceRepository repository;

  String call() => repository.generateVolumeId();
}

class FetchSequenceVolumesUseCase {
  const FetchSequenceVolumesUseCase(this.repository);
  final SequenceRepository repository;

  Future<List<SequenceVolumeEntity>> call(String sequenceId) =>
      repository.fetchSequenceVolumes(sequenceId);
}

class FetchSequenceVolumeByIdUseCase {
  const FetchSequenceVolumeByIdUseCase(this.repository);
  final SequenceRepository repository;

  Future<SequenceVolumeEntity?> call(String id) => repository.fetchSequenceVolumeById(id);
}

class FetchSequenceVolumesByBookIdUseCase {
  const FetchSequenceVolumesByBookIdUseCase(this.repository);
  final SequenceRepository repository;

  Future<List<SequenceVolumeEntity>> call(String bookId) =>
      repository.fetchSequenceVolumesByBookId(bookId);
}

class FetchSequenceVolumesByWorkIdUseCase {
  const FetchSequenceVolumesByWorkIdUseCase(this.repository);
  final SequenceRepository repository;

  Future<List<SequenceVolumeEntity>> call(String workId) =>
      repository.fetchSequenceVolumesByWorkId(workId);
}

class WatchSequenceVolumesUseCase {
  const WatchSequenceVolumesUseCase(this.repository);
  final SequenceRepository repository;

  Stream<List<SequenceVolumeEntity>> call(String sequenceId) =>
      repository.watchSequenceVolumes(sequenceId);
}

class AddSequenceVolumeUseCase {
  const AddSequenceVolumeUseCase(this.repository);
  final SequenceRepository repository;

  Future<void> call(SequenceVolumeEntity volume) => repository.addSequenceVolume(volume);
}

class EditSequenceVolumeUseCase {
  const EditSequenceVolumeUseCase(this.repository);
  final SequenceRepository repository;

  Future<void> call(SequenceVolumeEntity volume) => repository.editSequenceVolume(volume);
}

class RemoveSequenceVolumeUseCase {
  const RemoveSequenceVolumeUseCase(this.repository);
  final SequenceRepository repository;

  Future<void> call(String id) => repository.removeSequenceVolume(id);
}

class SyncBookSequenceVolumesUseCase {
  const SyncBookSequenceVolumesUseCase(this.repository);
  final SequenceRepository repository;

  Future<List<String>> call({
    required String bookId,
    required Map<SequenceEntity, String> entries,
    bool isEdit = false,
  }) async {
    if (isEdit) {
      final List<SequenceVolumeEntity> oldVolumes = await repository.fetchSequenceVolumesByBookId(
        bookId,
      );

      for (final SequenceVolumeEntity vol in oldVolumes) {
        await repository.removeSequenceVolume(vol.id);
      }
    }

    final List<String> volumeIds = <String>[];

    for (final MapEntry<SequenceEntity, String> entry in entries.entries) {
      final String id = repository.generateVolumeId();
      await repository.addSequenceVolume(
        SequenceVolumeEntity(
          id: id,
          volume: entry.value,
          sequenceId: entry.key.id,
          bookId: bookId,
          createdDate: DateTime.now(),
          lastUpdated: DateTime.now(),
        ),
      );

      volumeIds.add(id);
    }

    return volumeIds;
  }
}

class SyncWorkSequenceVolumesUseCase {
  const SyncWorkSequenceVolumesUseCase(this.repository);
  final SequenceRepository repository;

  Future<List<String>> call({
    required String workId,
    required Map<SequenceEntity, String> entries,
    bool isEdit = false,
  }) async {
    if (isEdit) {
      final List<SequenceVolumeEntity> oldVolumes = await repository.fetchSequenceVolumesByWorkId(
        workId,
      );

      for (final SequenceVolumeEntity vol in oldVolumes) {
        await repository.removeSequenceVolume(vol.id);
      }
    }

    final List<String> volumeIds = <String>[];

    for (final MapEntry<SequenceEntity, String> entry in entries.entries) {
      final String id = repository.generateVolumeId();
      await repository.addSequenceVolume(
        SequenceVolumeEntity(
          id: id,
          volume: entry.value,
          sequenceId: entry.key.id,
          workId: workId,
          createdDate: DateTime.now(),
          lastUpdated: DateTime.now(),
        ),
      );

      volumeIds.add(id);
    }

    return volumeIds;
  }
}

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
FetchSequenceCountUseCase fetchSequenceCountUseCase(Ref ref) =>
    FetchSequenceCountUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
AddSequenceUseCase addSequenceUseCase(Ref ref) =>
    AddSequenceUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
EditSequenceUseCase editSequenceUseCase(Ref ref) =>
    EditSequenceUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
RemoveSequenceUseCase removeSequenceUseCase(Ref ref) =>
    RemoveSequenceUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
GenerateSequenceVolumeIdUseCase generateSequenceVolumeIdUseCase(Ref ref) =>
    GenerateSequenceVolumeIdUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
FetchSequenceVolumesUseCase fetchSequenceVolumesUseCase(Ref ref) =>
    FetchSequenceVolumesUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
FetchSequenceVolumeByIdUseCase fetchSequenceVolumeByIdUseCase(Ref ref) =>
    FetchSequenceVolumeByIdUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
FetchSequenceVolumesByBookIdUseCase fetchSequenceVolumesByBookIdUseCase(Ref ref) =>
    FetchSequenceVolumesByBookIdUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
FetchSequenceVolumesByWorkIdUseCase fetchSequenceVolumesByWorkIdUseCase(Ref ref) =>
    FetchSequenceVolumesByWorkIdUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
WatchSequenceVolumesUseCase watchSequenceVolumesUseCase(Ref ref) =>
    WatchSequenceVolumesUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
AddSequenceVolumeUseCase addSequenceVolumeUseCase(Ref ref) =>
    AddSequenceVolumeUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
EditSequenceVolumeUseCase editSequenceVolumeUseCase(Ref ref) =>
    EditSequenceVolumeUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
RemoveSequenceVolumeUseCase removeSequenceVolumeUseCase(Ref ref) =>
    RemoveSequenceVolumeUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
SyncBookSequenceVolumesUseCase syncBookSequenceVolumesUseCase(Ref ref) =>
    SyncBookSequenceVolumesUseCase(ref.watch(sequenceRepositoryProvider));

@riverpod
SyncWorkSequenceVolumesUseCase syncWorkSequenceVolumesUseCase(Ref ref) =>
    SyncWorkSequenceVolumesUseCase(ref.watch(sequenceRepositoryProvider));
