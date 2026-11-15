import '../entities/sequence_entity.dart';
import '../entities/sequence_volume_entity.dart';
import '../repositories/sequence_volume_repository.dart';

class GenerateSequenceVolumeIdUseCase {
  const GenerateSequenceVolumeIdUseCase(this.repository);
  final SequenceVolumeRepository repository;

  String call() => repository.generateId();
}

class FetchSequenceVolumesUseCase {
  const FetchSequenceVolumesUseCase(this.repository);
  final SequenceVolumeRepository repository;

  Future<List<SequenceVolumeEntity>> call(String sequenceId) =>
      repository.fetchSequenceVolumes(sequenceId);
}

class FetchSequenceVolumeByIdUseCase {
  const FetchSequenceVolumeByIdUseCase(this.repository);
  final SequenceVolumeRepository repository;

  Future<SequenceVolumeEntity?> call(String id) => repository.fetchSequenceVolumeById(id);
}

class FetchSequenceVolumesByBookIdUseCase {
  const FetchSequenceVolumesByBookIdUseCase(this.repository);
  final SequenceVolumeRepository repository;

  Future<List<SequenceVolumeEntity>> call(String bookId) =>
      repository.fetchSequenceVolumesByBookId(bookId);
}

class FetchSequenceVolumesByWorkIdUseCase {
  const FetchSequenceVolumesByWorkIdUseCase(this.repository);
  final SequenceVolumeRepository repository;

  Future<List<SequenceVolumeEntity>> call(String workId) =>
      repository.fetchSequenceVolumesByWorkId(workId);
}

class WatchSequenceVolumesUseCase {
  const WatchSequenceVolumesUseCase(this.repository);
  final SequenceVolumeRepository repository;

  Stream<List<SequenceVolumeEntity>> call(String sequenceId) =>
      repository.watchSequenceVolumes(sequenceId);
}

class WatchAllSequenceVolumesUseCase {
  const WatchAllSequenceVolumesUseCase(this.repository);
  final SequenceVolumeRepository repository;

  Stream<List<SequenceVolumeEntity>> call() => repository.watchAllSequenceVolumes();
}

class AddSequenceVolumeUseCase {
  const AddSequenceVolumeUseCase(this.repository);
  final SequenceVolumeRepository repository;

  Future<void> call(SequenceVolumeEntity volume) => repository.addSequenceVolume(volume);
}

class EditSequenceVolumeUseCase {
  const EditSequenceVolumeUseCase(this.repository);
  final SequenceVolumeRepository repository;

  Future<void> call(SequenceVolumeEntity volume, {SequenceVolumeEntity? oldVolume}) =>
      repository.editSequenceVolume(volume, oldVolume: oldVolume);
}

class RemoveSequenceVolumeUseCase {
  const RemoveSequenceVolumeUseCase(this.repository);
  final SequenceVolumeRepository repository;

  Future<void> call(String id) => repository.removeSequenceVolume(id);
}

class SyncBookSequenceVolumesUseCase {
  const SyncBookSequenceVolumesUseCase(this.repository);
  final SequenceVolumeRepository repository;

  Future<List<String>> call({
    required String bookId,
    required Map<SequenceEntity, String> entries,
    bool isEdit = false,
  }) => repository.syncBookVolumes(
    bookId,
    entries.map((SequenceEntity k, String v) => MapEntry<String, String>(k.id, v)),
    isEdit,
  );
}

class SyncWorkSequenceVolumesUseCase {
  const SyncWorkSequenceVolumesUseCase(this.repository);
  final SequenceVolumeRepository repository;

  Future<List<String>> call({
    required String workId,
    required Map<SequenceEntity, String> entries,
    bool isEdit = false,
  }) => repository.syncWorkVolumes(
    workId,
    entries.map((SequenceEntity k, String v) => MapEntry<String, String>(k.id, v)),
    isEdit,
  );
}
