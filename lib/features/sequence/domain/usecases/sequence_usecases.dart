import '../entities/sequence_entity.dart';
import '../entities/sequence_volume_entity.dart';
import '../repositories/sequence_repository.dart';

class GetSequencesUseCase {
  const GetSequencesUseCase(this.repository);
  final SequenceRepository repository;

  Future<List<SequenceEntity>> call() => repository.getSequences();
}

class WatchSequencesUseCase {
  const WatchSequencesUseCase(this.repository);
  final SequenceRepository repository;

  Stream<List<SequenceEntity>> call() => repository.watchSequences();
}

class GetSequenceByIdUseCase {
  const GetSequenceByIdUseCase(this.repository);
  final SequenceRepository repository;

  Future<SequenceEntity?> call(String id) => repository.getSequenceById(id);
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

class GetSequenceVolumesUseCase {
  const GetSequenceVolumesUseCase(this.repository);
  final SequenceRepository repository;

  Future<List<SequenceVolumeEntity>> call(String sequenceId) =>
      repository.getSequenceVolumes(sequenceId);
}

class GetSequenceVolumeByIdUseCase {
  const GetSequenceVolumeByIdUseCase(this.repository);
  final SequenceRepository repository;

  Future<SequenceVolumeEntity?> call(String id) => repository.getSequenceVolumeById(id);
}

class GetSequenceVolumesByBookIdUseCase {
  const GetSequenceVolumesByBookIdUseCase(this.repository);
  final SequenceRepository repository;

  Future<List<SequenceVolumeEntity>> call(String bookId) =>
      repository.getSequenceVolumesByBookId(bookId);
}

class GetSequenceVolumesByWorkIdUseCase {
  const GetSequenceVolumesByWorkIdUseCase(this.repository);
  final SequenceRepository repository;

  Future<List<SequenceVolumeEntity>> call(String workId) =>
      repository.getSequenceVolumesByWorkId(workId);
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

class WatchSequenceVolumesUseCase {
  const WatchSequenceVolumesUseCase(this.repository);
  final SequenceRepository repository;

  Stream<List<SequenceVolumeEntity>> call(String sequenceId) =>
      repository.watchSequenceVolumes(sequenceId);
}
