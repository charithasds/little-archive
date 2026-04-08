import '../../../../core/shared/domain/usecases/usecase.dart';
import '../../domain/entities/sequence_entity.dart';
import '../../domain/entities/sequence_volume_entity.dart';
import '../../domain/repositories/sequence_repository.dart';

class GetSequencesUseCase implements UseCase<List<SequenceEntity>, String> {
  GetSequencesUseCase(this.repository);
  final SequenceRepository repository;

  @override
  Future<List<SequenceEntity>> call(String params) => repository.getSequences(params);
}

class WatchSequencesUseCase implements UseCase<Stream<List<SequenceEntity>>, String> {
  WatchSequencesUseCase(this.repository);
  final SequenceRepository repository;

  @override
  Future<Stream<List<SequenceEntity>>> call(String params) async =>
      repository.watchSequences(params);
}

class AddSequenceUseCase implements UseCase<void, SequenceEntity> {
  AddSequenceUseCase(this.repository);
  final SequenceRepository repository;

  @override
  Future<void> call(SequenceEntity params) => repository.addSequence(params);
}

class UpdateSequenceUseCase implements UseCase<void, SequenceEntity> {
  UpdateSequenceUseCase(this.repository);
  final SequenceRepository repository;

  @override
  Future<void> call(SequenceEntity params) => repository.updateSequence(params);
}

class DeleteSequenceUseCase implements UseCase<void, String> {
  DeleteSequenceUseCase(this.repository);
  final SequenceRepository repository;

  @override
  Future<void> call(String params) => repository.deleteSequence(params);
}

class GetSequenceVolumeByIdUseCase implements UseCase<SequenceVolumeEntity?, String> {
  GetSequenceVolumeByIdUseCase(this.repository);
  final SequenceRepository repository;

  @override
  Future<SequenceVolumeEntity?> call(String params) => repository.getSequenceVolumeById(params);
}

class GetSequenceVolumesByBookIdParams {
  GetSequenceVolumesByBookIdParams({required this.bookId, required this.userId});
  final String bookId;
  final String userId;
}

class GetSequenceVolumesByBookIdUseCase
    implements UseCase<List<SequenceVolumeEntity>, GetSequenceVolumesByBookIdParams> {
  GetSequenceVolumesByBookIdUseCase(this.repository);
  final SequenceRepository repository;

  @override
  Future<List<SequenceVolumeEntity>> call(GetSequenceVolumesByBookIdParams params) =>
      repository.getSequenceVolumesByBookId(params.bookId, params.userId);
}

class GetSequenceVolumesByWorkIdParams {
  GetSequenceVolumesByWorkIdParams({required this.workId, required this.userId});
  final String workId;
  final String userId;
}

class GetSequenceVolumesByWorkIdUseCase
    implements UseCase<List<SequenceVolumeEntity>, GetSequenceVolumesByWorkIdParams> {
  GetSequenceVolumesByWorkIdUseCase(this.repository);
  final SequenceRepository repository;

  @override
  Future<List<SequenceVolumeEntity>> call(GetSequenceVolumesByWorkIdParams params) =>
      repository.getSequenceVolumesByWorkId(params.workId, params.userId);
}
