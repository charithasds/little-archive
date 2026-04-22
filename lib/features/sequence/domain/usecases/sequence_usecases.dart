import '../entities/sequence_entity.dart';
import '../entities/sequence_volume_entity.dart';
import '../repositories/sequence_repository.dart';

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
