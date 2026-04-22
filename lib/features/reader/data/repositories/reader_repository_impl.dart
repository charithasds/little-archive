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
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<ReaderEntity>> fetchReaders() => remoteDataSource.fetchReaders();

  @override
  Future<ReaderEntity?> fetchReaderById(String id) => remoteDataSource.fetchReaderById(id);

  @override
  Stream<List<ReaderEntity>> watchReaders() => remoteDataSource.watchReaders();

  @override
  Future<void> addReader(ReaderEntity reader) async {
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
    );

    await relationshipSyncService.syncReaderRelationships(
      readerId: reader.id,
      newBookIds: reader.bookIds,
    );
  }

  @override
  Future<void> editReader(ReaderEntity reader) async {
    final ReaderModel? existingReader = await remoteDataSource.fetchReaderById(reader.id);

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
    );

    await relationshipSyncService.syncReaderRelationships(
      readerId: reader.id,
      newBookIds: reader.bookIds,
      oldBookIds: existingReader?.bookIds ?? <String>[],
    );
  }

  @override
  Future<void> removeReader(String id) async {
    final ReaderModel? existingReader = await remoteDataSource.fetchReaderById(id);

    if (existingReader != null) {
      await relationshipSyncService.removeReaderRelationships(
        readerId: id,
        bookIds: existingReader.bookIds,
      );
    }

    await remoteDataSource.removeReader(id);
  }
}
