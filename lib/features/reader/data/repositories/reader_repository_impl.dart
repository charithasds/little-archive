import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../domain/entities/reader_entity.dart';
import '../../domain/repositories/reader_repository.dart';
import '../datasources/reader_remote_datasource.dart';
import '../models/reader_model.dart';

part 'reader_repository_impl.g.dart';

class ReaderRepositoryImpl implements ReaderRepository {
  ReaderRepositoryImpl({required this.remoteDataSource, required this.relationshipSyncService});

  final ReaderRemoteDataSource remoteDataSource;
  final RelationshipSyncService relationshipSyncService;

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<ReaderEntity>> fetchReaders() => remoteDataSource.fetchReaders();

  @override
  Future<ReaderEntity?> fetchReaderById(String id) => remoteDataSource.fetchReaderById(id);

  @override
  Stream<List<ReaderEntity>> watchReaders() => remoteDataSource.watchReaders();

  @override
  Future<void> addReader(ReaderEntity reader, {WriteBatch? batch}) async {
    await remoteDataSource.addReader(
      ReaderModel(
        id: reader.id,
        name: reader.name,
        image: reader.image,
        otherName: reader.otherName,
        email: reader.email,
        facebook: reader.facebook,
        phoneNumber: reader.phoneNumber,
        bookIds: reader.bookIds,
        createdDate: reader.createdDate,
        lastUpdated: reader.lastUpdated,
      ),
      batch: batch,
    );

    await relationshipSyncService.syncReaderRelationships(
      readerId: reader.id,
      newBookIds: reader.bookIds,
      batch: batch,
    );
  }

  @override
  Future<void> editReader(ReaderEntity reader, {ReaderEntity? oldReader, WriteBatch? batch}) async {
    final List<String> oldBookIds;

    if (oldReader != null) {
      oldBookIds = oldReader.bookIds;
    } else {
      final ReaderModel? existingReader = await remoteDataSource.fetchReaderById(reader.id);
      oldBookIds = existingReader?.bookIds ?? <String>[];
    }

    await remoteDataSource.editReader(
      ReaderModel(
        id: reader.id,
        name: reader.name,
        image: reader.image,
        otherName: reader.otherName,
        email: reader.email,
        facebook: reader.facebook,
        phoneNumber: reader.phoneNumber,
        bookIds: reader.bookIds,
        createdDate: reader.createdDate,
        lastUpdated: reader.lastUpdated,
      ),
      batch: batch,
    );

    await relationshipSyncService.syncReaderRelationships(
      readerId: reader.id,
      newBookIds: reader.bookIds,
      oldBookIds: oldBookIds,
      batch: batch,
    );
  }

  @override
  Future<void> removeReader(String id, {WriteBatch? batch}) async {
    final ReaderModel? existingReader = await remoteDataSource.fetchReaderById(id);

    if (existingReader != null) {
      await relationshipSyncService.removeReaderRelationships(
        readerId: id,
        bookIds: existingReader.bookIds,
        batch: batch,
      );
    }

    await remoteDataSource.removeReader(id, batch: batch);
  }
}

@riverpod
ReaderRepository readerRepository(Ref ref) {
  final ReaderRemoteDataSource remoteDataSource = ref.watch(readerRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return ReaderRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}
