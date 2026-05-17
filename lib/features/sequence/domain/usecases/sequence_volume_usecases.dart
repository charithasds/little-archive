import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/sequence_volume_repository_impl.dart';
import '../entities/sequence_entity.dart';
import '../entities/sequence_volume_entity.dart';
import '../repositories/sequence_volume_repository.dart';

part 'sequence_volume_usecases.g.dart';

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

  Future<void> call(SequenceVolumeEntity volume) => repository.editSequenceVolume(volume);
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
    WriteBatch? batch,
  }) => repository.syncBookVolumes(
    bookId,
    entries.map((SequenceEntity k, String v) => MapEntry<String, String>(k.id, v)),
    isEdit,
    batch: batch,
  );
}

class SyncWorkSequenceVolumesUseCase {
  const SyncWorkSequenceVolumesUseCase(this.repository);
  final SequenceVolumeRepository repository;

  Future<List<String>> call({
    required String workId,
    required Map<SequenceEntity, String> entries,
    bool isEdit = false,
    WriteBatch? batch,
  }) => repository.syncWorkVolumes(
    workId,
    entries.map((SequenceEntity k, String v) => MapEntry<String, String>(k.id, v)),
    isEdit,
    batch: batch,
  );
}

@riverpod
GenerateSequenceVolumeIdUseCase generateSequenceVolumeIdUseCase(Ref ref) =>
    GenerateSequenceVolumeIdUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
FetchSequenceVolumesUseCase fetchSequenceVolumesUseCase(Ref ref) =>
    FetchSequenceVolumesUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
FetchSequenceVolumeByIdUseCase fetchSequenceVolumeByIdUseCase(Ref ref) =>
    FetchSequenceVolumeByIdUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
FetchSequenceVolumesByBookIdUseCase fetchSequenceVolumesByBookIdUseCase(Ref ref) =>
    FetchSequenceVolumesByBookIdUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
FetchSequenceVolumesByWorkIdUseCase fetchSequenceVolumesByWorkIdUseCase(Ref ref) =>
    FetchSequenceVolumesByWorkIdUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
WatchSequenceVolumesUseCase watchSequenceVolumesUseCase(Ref ref) =>
    WatchSequenceVolumesUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
WatchAllSequenceVolumesUseCase watchAllSequenceVolumesUseCase(Ref ref) =>
    WatchAllSequenceVolumesUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
AddSequenceVolumeUseCase addSequenceVolumeUseCase(Ref ref) =>
    AddSequenceVolumeUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
EditSequenceVolumeUseCase editSequenceVolumeUseCase(Ref ref) =>
    EditSequenceVolumeUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
RemoveSequenceVolumeUseCase removeSequenceVolumeUseCase(Ref ref) =>
    RemoveSequenceVolumeUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
SyncBookSequenceVolumesUseCase syncBookSequenceVolumesUseCase(Ref ref) =>
    SyncBookSequenceVolumesUseCase(ref.watch(sequenceVolumeRepositoryProvider));

@riverpod
SyncWorkSequenceVolumesUseCase syncWorkSequenceVolumesUseCase(Ref ref) =>
    SyncWorkSequenceVolumesUseCase(ref.watch(sequenceVolumeRepositoryProvider));
