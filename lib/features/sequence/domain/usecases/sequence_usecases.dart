import '../entities/sequence_entity.dart';
import '../repositories/sequence_repository.dart';

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

class AddSequenceUseCase {
  const AddSequenceUseCase(this.repository);
  final SequenceRepository repository;

  Future<void> call(SequenceEntity sequence) => repository.addSequence(sequence);
}

class EditSequenceUseCase {
  const EditSequenceUseCase(this.repository);
  final SequenceRepository repository;

  Future<void> call(SequenceEntity sequence, {SequenceEntity? oldSequence}) =>
      repository.editSequence(sequence, oldSequence: oldSequence);
}

class RemoveSequenceUseCase {
  const RemoveSequenceUseCase(this.repository);
  final SequenceRepository repository;

  Future<void> call(String id) => repository.removeSequence(id);
}
