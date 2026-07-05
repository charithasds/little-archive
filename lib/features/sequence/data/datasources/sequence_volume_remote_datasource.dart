import 'dart:math';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../models/sequence_volume_model.dart';

part 'sequence_volume_remote_datasource.g.dart';

abstract class SequenceVolumeRemoteDataSource {
  String generateId();

  Future<List<SequenceVolumeModel>> fetchSequenceVolumes(String sequenceId);
  Future<SequenceVolumeModel?> fetchSequenceVolumeById(String id);
  Future<List<SequenceVolumeModel>> fetchSequenceVolumesByBookId(String bookId);
  Future<List<SequenceVolumeModel>> fetchSequenceVolumesByWorkId(String workId);
  Stream<List<SequenceVolumeModel>> watchSequenceVolumes(String sequenceId);
  Stream<List<SequenceVolumeModel>> watchAllSequenceVolumes();
  Future<void> addSequenceVolume(SequenceVolumeModel volume);
  Future<void> editSequenceVolume(SequenceVolumeModel volume);
  Future<void> removeSequenceVolume(String id);
}

class SequenceVolumeRemoteDataSourceImpl implements SequenceVolumeRemoteDataSource {
  SequenceVolumeRemoteDataSourceImpl({required this.db});

  final AppDatabase db;

  @override
  String generateId() {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    return List<String>.generate(20, (_) => chars[random.nextInt(chars.length)]).join();
  }

  SequenceVolumeModel _mapToSequenceVolumeModel(SequenceVolume row) => SequenceVolumeModel(
      id: row.id,
      volume: row.volume,
      sequenceId: row.sequenceId,
      bookId: row.bookId,
      workId: row.workId,
      createdDate: row.createdDate,
      lastUpdated: row.lastUpdated,
    );

  @override
  Future<List<SequenceVolumeModel>> fetchSequenceVolumes(String sequenceId) async {
    final SimpleSelectStatement<$SequenceVolumesTable, SequenceVolume> query = db.select(db.sequenceVolumes)..where(($SequenceVolumesTable t) => t.sequenceId.equals(sequenceId));
    final List<SequenceVolume> rows = await query.get();
    return rows.map(_mapToSequenceVolumeModel).toList();
  }

  @override
  Future<SequenceVolumeModel?> fetchSequenceVolumeById(String id) async {
    final SimpleSelectStatement<$SequenceVolumesTable, SequenceVolume> query = db.select(db.sequenceVolumes)..where(($SequenceVolumesTable t) => t.id.equals(id));
    final SequenceVolume? row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapToSequenceVolumeModel(row);
  }

  @override
  Future<List<SequenceVolumeModel>> fetchSequenceVolumesByBookId(String bookId) async {
    final SimpleSelectStatement<$SequenceVolumesTable, SequenceVolume> query = db.select(db.sequenceVolumes)..where(($SequenceVolumesTable t) => t.bookId.equals(bookId));
    final List<SequenceVolume> rows = await query.get();
    return rows.map(_mapToSequenceVolumeModel).toList();
  }

  @override
  Future<List<SequenceVolumeModel>> fetchSequenceVolumesByWorkId(String workId) async {
    final SimpleSelectStatement<$SequenceVolumesTable, SequenceVolume> query = db.select(db.sequenceVolumes)..where(($SequenceVolumesTable t) => t.workId.equals(workId));
    final List<SequenceVolume> rows = await query.get();
    return rows.map(_mapToSequenceVolumeModel).toList();
  }

  @override
  Stream<List<SequenceVolumeModel>> watchSequenceVolumes(String sequenceId) => (db.select(db.sequenceVolumes)..where(($SequenceVolumesTable t) => t.sequenceId.equals(sequenceId)))
        .watch()
        .map((List<SequenceVolume> rows) => rows.map(_mapToSequenceVolumeModel).toList());

  @override
  Stream<List<SequenceVolumeModel>> watchAllSequenceVolumes() => db.select(db.sequenceVolumes)
        .watch()
        .map((List<SequenceVolume> rows) => rows.map(_mapToSequenceVolumeModel).toList());

  @override
  Future<void> addSequenceVolume(SequenceVolumeModel volume) async {
    await db.into(db.sequenceVolumes).insertOnConflictUpdate(
      SequenceVolume(
        id: volume.id,
        volume: volume.volume,
        sequenceId: volume.sequenceId,
        bookId: volume.bookId,
        workId: volume.workId,
        createdDate: volume.createdDate,
        lastUpdated: volume.lastUpdated,
      ).toCompanion(false),
    );
  }

  @override
  Future<void> editSequenceVolume(SequenceVolumeModel volume) async {
    await addSequenceVolume(volume);
  }

  @override
  Future<void> removeSequenceVolume(String id) async {
    await (db.delete(db.sequenceVolumes)..where(($SequenceVolumesTable t) => t.id.equals(id))).go();
  }
}

@riverpod
SequenceVolumeRemoteDataSource sequenceVolumeRemoteDataSource(Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return SequenceVolumeRemoteDataSourceImpl(db: db);
}
