import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/sequence_volume_entity.dart';
import '../../domain/repositories/sequence_volume_repository.dart';
import '../datasources/sequence_volume_remote_datasource.dart';
import '../models/sequence_volume_model.dart';

part 'sequence_volume_repository_impl.g.dart';

class SequenceVolumeRepositoryImpl implements SequenceVolumeRepository {
  SequenceVolumeRepositoryImpl({
    required this.remoteDataSource,
  });

  final SequenceVolumeRemoteDataSource remoteDataSource;

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<SequenceVolumeEntity>> fetchSequenceVolumes(String sequenceId) =>
      remoteDataSource.fetchSequenceVolumes(sequenceId);

  @override
  Future<SequenceVolumeEntity?> fetchSequenceVolumeById(String id) =>
      remoteDataSource.fetchSequenceVolumeById(id);

  @override
  Future<List<SequenceVolumeEntity>> fetchSequenceVolumesByBookId(String bookId) =>
      remoteDataSource.fetchSequenceVolumesByBookId(bookId);

  @override
  Future<List<SequenceVolumeEntity>> fetchSequenceVolumesByWorkId(String workId) =>
      remoteDataSource.fetchSequenceVolumesByWorkId(workId);

  @override
  Stream<List<SequenceVolumeEntity>> watchSequenceVolumes(String sequenceId) =>
      remoteDataSource.watchSequenceVolumes(sequenceId);

  @override
  Stream<List<SequenceVolumeEntity>> watchAllSequenceVolumes() =>
      remoteDataSource.watchAllSequenceVolumes();

  @override
  Future<void> addSequenceVolume(SequenceVolumeEntity volume) async {
    await remoteDataSource.addSequenceVolume(
      SequenceVolumeModel(
        id: volume.id,
        volume: volume.volume,
        sequenceId: volume.sequenceId,
        bookId: volume.bookId,
        workId: volume.workId,
        createdDate: volume.createdDate,
        lastUpdated: volume.lastUpdated,
      ),
    );
  }

  @override
  Future<void> editSequenceVolume(SequenceVolumeEntity volume, {SequenceVolumeEntity? oldVolume}) async {
    await remoteDataSource.editSequenceVolume(
      SequenceVolumeModel(
        id: volume.id,
        volume: volume.volume,
        sequenceId: volume.sequenceId,
        bookId: volume.bookId,
        workId: volume.workId,
        createdDate: volume.createdDate,
        lastUpdated: volume.lastUpdated,
      ),
    );
  }

  @override
  Future<void> removeSequenceVolume(String id) async {
    await remoteDataSource.removeSequenceVolume(id);
  }

  @override
  Future<List<String>> syncBookVolumes(
    String bookId,
    Map<String, String> sequenceIdToVolume,
    bool isEdit,
  ) async {
    if (isEdit) {
      final List<SequenceVolumeEntity> oldVolumes = await fetchSequenceVolumesByBookId(bookId);

      for (final SequenceVolumeEntity vol in oldVolumes) {
        await removeSequenceVolume(vol.id);
      }
    }

    final List<String> volumeIds = <String>[];

    for (final MapEntry<String, String> entry in sequenceIdToVolume.entries) {
      final String id = generateId();

      await addSequenceVolume(
        SequenceVolumeEntity(
          id: id,
          volume: entry.value,
          sequenceId: entry.key,
          bookId: bookId,
          createdDate: DateTime.now(),
          lastUpdated: DateTime.now(),
        ),
      );

      volumeIds.add(id);
    }

    return volumeIds;
  }

  @override
  Future<List<String>> syncWorkVolumes(
    String workId,
    Map<String, String> sequenceIdToVolume,
    bool isEdit,
  ) async {
    if (isEdit) {
      final List<SequenceVolumeEntity> oldVolumes = await fetchSequenceVolumesByWorkId(workId);

      for (final SequenceVolumeEntity vol in oldVolumes) {
        await removeSequenceVolume(vol.id);
      }
    }

    final List<String> volumeIds = <String>[];

    for (final MapEntry<String, String> entry in sequenceIdToVolume.entries) {
      final String id = generateId();

      await addSequenceVolume(
        SequenceVolumeEntity(
          id: id,
          volume: entry.value,
          sequenceId: entry.key,
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
SequenceVolumeRepository sequenceVolumeRepository(Ref ref) {
  final SequenceVolumeRemoteDataSource remoteDataSource = ref.watch(
    sequenceVolumeRemoteDataSourceProvider,
  );

  return SequenceVolumeRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
}
