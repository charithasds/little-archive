import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../models/sequence_model.dart';

part 'sequence_remote_datasource.g.dart';

abstract class SequenceRemoteDataSource {
  String generateId();
  Future<List<SequenceModel>> fetchSequences();
  Future<SequenceModel?> fetchSequenceById(String id);
  Stream<List<SequenceModel>> watchSequences();
  Future<void> addSequence(SequenceModel sequence);
  Future<void> editSequence(SequenceModel sequence);
  Future<void> removeSequence(String id);
}

class SequenceRemoteDataSourceImpl implements SequenceRemoteDataSource {
  SequenceRemoteDataSourceImpl({required this.db});

  final AppDatabase db;

  @override
  String generateId() {
    final Random random = Random();
    final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '').replaceAll('-', '').replaceAll('_', '').substring(0, 20);
  }

  Future<SequenceModel> _mapToSequenceModel(Sequence row) async {
    // Resolve sequenceVolumeIds where sequenceId == row.id
    final SimpleSelectStatement<$SequenceVolumesTable, SequenceVolume> volumesQuery = db.select(db.sequenceVolumes)..where(($SequenceVolumesTable t) => t.sequenceId.equals(row.id));
    final List<SequenceVolume> volumes = await volumesQuery.get();
    final List<String> sequenceVolumeIds = volumes.map((SequenceVolume v) => v.id).toList();

    return SequenceModel(
      id: row.id,
      name: row.name,
      notes: row.notes,
      sequenceVolumeIds: sequenceVolumeIds,
      createdDate: row.createdDate,
      lastUpdated: row.lastUpdated,
    );
  }

  @override
  Future<List<SequenceModel>> fetchSequences() async {
    final SimpleSelectStatement<$SequencesTable, Sequence> query = db.select(db.sequences)..orderBy(<OrderClauseGenerator<$SequencesTable>>[($SequencesTable t) => OrderingTerm(expression: t.name)]);
    final List<Sequence> rows = await query.get();
    final List<SequenceModel> sequences = <SequenceModel>[];
    for (final Sequence row in rows) {
      sequences.add(await _mapToSequenceModel(row));
    }
    return sequences;
  }

  @override
  Future<SequenceModel?> fetchSequenceById(String id) async {
    final SimpleSelectStatement<$SequencesTable, Sequence> query = db.select(db.sequences)..where(($SequencesTable t) => t.id.equals(id));
    final Sequence? row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapToSequenceModel(row);
  }

  @override
  Stream<List<SequenceModel>> watchSequences() => db.select(db.sequences).watch().asyncMap((List<Sequence> rows) async {
      final List<SequenceModel> sequences = <SequenceModel>[];
      for (final Sequence row in rows) {
        sequences.add(await _mapToSequenceModel(row));
      }
      return sequences;
    });

  @override
  Future<void> addSequence(SequenceModel sequence) async {
    await db.into(db.sequences).insertOnConflictUpdate(
      Sequence(
        id: sequence.id,
        name: sequence.name,
        notes: sequence.notes,
        createdDate: sequence.createdDate,
        lastUpdated: sequence.lastUpdated,
      ),
    );
  }

  @override
  Future<void> editSequence(SequenceModel sequence) async {
    await addSequence(sequence);
  }

  @override
  Future<void> removeSequence(String id) async {
    await (db.delete(db.sequences)..where(($SequencesTable t) => t.id.equals(id))).go();
  }
}

@riverpod
SequenceRemoteDataSource sequenceRemoteDataSource(Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return SequenceRemoteDataSourceImpl(db: db);
}
