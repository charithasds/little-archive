import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../domain/entities/reader_entity.dart';
import '../../domain/repositories/reader_repository.dart';
import '../datasources/reader_remote_datasource.dart';
import '../models/reader_model.dart';

class ReaderRepositoryImpl implements ReaderRepository {
  ReaderRepositoryImpl({required this.remoteDataSource, required this.relationshipSyncService});
  final ReaderRemoteDataSource remoteDataSource;
  final RelationshipSyncService relationshipSyncService;

  @override
  Future<List<ReaderEntity>> getReaders(String userId) => remoteDataSource.getReaders(userId);

  @override
  Future<ReaderEntity?> getReaderById(String id) => remoteDataSource.getReaderById(id);

  @override
  Future<void> addReader(ReaderEntity reader) => remoteDataSource.addReader(
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
  );

  @override
  Future<void> updateReader(ReaderEntity reader) => remoteDataSource.updateReader(
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
  );

  @override
  Future<void> deleteReader(String id) async {
    final ReaderModel? existingReader = await remoteDataSource.getReaderById(id);
    if (existingReader != null) {
      await relationshipSyncService.removeReaderRelationships(
        readerId: id,
        bookIds: existingReader.bookIds,
      );
    }
    await remoteDataSource.deleteReader(id);
  }

  @override
  Stream<List<ReaderEntity>> watchReaders(String userId) => remoteDataSource.watchReaders(userId);
}
