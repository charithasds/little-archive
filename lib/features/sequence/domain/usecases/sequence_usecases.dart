import '../entities/sequence_entity.dart';
import '../entities/sequence_volume_entity.dart';
import '../repositories/sequence_repository.dart';

class GetSequencesUseCase {
  const GetSequencesUseCase(this.repository);
  final SequenceRepository repository;

  Future<List<SequenceEntity>> call(String userId) => repository.getSequences(userId);
}

class WatchSequencesUseCase {
  const WatchSequencesUseCase(this.repository);
  final SequenceRepository repository;

  Stream<List<SequenceEntity>> call(String userId) => repository.watchSequences(userId);
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

class UpdateSequenceUseCase {
  const UpdateSequenceUseCase(this.repository);
  final SequenceRepository repository;

  Future<void> call(SequenceEntity sequence) => repository.updateSequence(sequence);
}

class DeleteSequenceUseCase {
  const DeleteSequenceUseCase(this.repository);
  final SequenceRepository repository;

  Future<void> call(String id) => repository.deleteSequence(id);
}

class GetSequenceVolumesUseCase {
  const GetSequenceVolumesUseCase(this.repository);
  final SequenceRepository repository;

  Future<List<SequenceVolumeEntity>> call(String sequenceId, String userId) =>
      repository.getSequenceVolumes(sequenceId, userId);
}

class GetSequenceVolumeByIdUseCase {
  const GetSequenceVolumeByIdUseCase(this.repository);
  final SequenceRepository repository;

  Future<SequenceVolumeEntity?> call(String id) => repository.getSequenceVolumeById(id);
}

class GetSequenceVolumesByBookIdUseCase {
  const GetSequenceVolumesByBookIdUseCase(this.repository);
  final SequenceRepository repository;

  Future<List<SequenceVolumeEntity>> call(String bookId, String userId) =>
      repository.getSequenceVolumesByBookId(bookId, userId);
}

class GetSequenceVolumesByWorkIdUseCase {
  const GetSequenceVolumesByWorkIdUseCase(this.repository);
  final SequenceRepository repository;

  Future<List<SequenceVolumeEntity>> call(String workId, String userId) =>
      repository.getSequenceVolumesByWorkId(workId, userId);
}

class AddSequenceVolumeUseCase {
  const AddSequenceVolumeUseCase(this.repository);
  final SequenceRepository repository;

  Future<void> call(SequenceVolumeEntity volume) => repository.addSequenceVolume(volume);
}

class UpdateSequenceVolumeUseCase {
  const UpdateSequenceVolumeUseCase(this.repository);
  final SequenceRepository repository;

  Future<void> call(SequenceVolumeEntity volume) => repository.updateSequenceVolume(volume);
}

class DeleteSequenceVolumeUseCase {
  const DeleteSequenceVolumeUseCase(this.repository);
  final SequenceRepository repository;

  Future<void> call(String id) => repository.deleteSequenceVolume(id);
}

class WatchSequenceVolumesUseCase {
  const WatchSequenceVolumesUseCase(this.repository);
  final SequenceRepository repository;

  Stream<List<SequenceVolumeEntity>> call(String sequenceId, String userId) =>
      repository.watchSequenceVolumes(sequenceId, userId);
}
