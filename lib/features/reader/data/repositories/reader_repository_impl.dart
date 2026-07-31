import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../domain/entities/reader_entity.dart';
import '../../domain/repositories/reader_repository.dart';
import '../datasources/reader_remote_datasource.dart';
import '../models/reader_model.dart';

part 'reader_repository_impl.g.dart';

class ReaderRepositoryImpl implements ReaderRepository {
  ReaderRepositoryImpl({required this.remoteDataSource});

  final ReaderRemoteDataSource remoteDataSource;

  final Set<String> _processedImageReaderIds = <String>{};

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<ReaderEntity>> fetchReaders() async {
    final List<ReaderEntity> readers = await remoteDataSource.fetchReaders();
    _compressExistingLargeImages(readers);
    return readers;
  }

  void _compressExistingLargeImages(List<ReaderEntity> readers) {
    Future<void>.microtask(() async {
      for (final ReaderEntity reader in readers) {
        if (_processedImageReaderIds.contains(reader.id)) {
          continue;
        }
        _processedImageReaderIds.add(reader.id);

        final String? image = reader.image;
        if (image != null && image.length > 50000) {
          final String? compressed = Images.compressImageIfNeeded(image);
          if (compressed != null && compressed != image) {
            final ReaderEntity updated = reader.copyWith(
              image: Nullable<String?>(compressed),
              lastUpdated: DateTime.now(),
            );
            await editReader(updated);
          }
        }
      }
    });
  }

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
        image: Images.compressImageIfNeeded(reader.image),
        otherName: reader.otherName,
        email: reader.email,
        facebook: reader.facebook,
        phoneNumber: reader.phoneNumber,
        bookIds: reader.bookIds,
        createdDate: reader.createdDate,
        lastUpdated: reader.lastUpdated,
      ),
    );
  }

  @override
  Future<void> editReader(ReaderEntity reader, {ReaderEntity? oldReader}) async {
    await remoteDataSource.editReader(
      ReaderModel(
        id: reader.id,
        name: reader.name,
        image: Images.compressImageIfNeeded(reader.image),
        otherName: reader.otherName,
        email: reader.email,
        facebook: reader.facebook,
        phoneNumber: reader.phoneNumber,
        bookIds: reader.bookIds,
        createdDate: reader.createdDate,
        lastUpdated: reader.lastUpdated,
      ),
    );
  }

  @override
  Future<void> removeReader(String id) async {
    await remoteDataSource.removeReader(id);
  }
}

@riverpod
ReaderRepository readerRepository(Ref ref) {
  final ReaderRemoteDataSource remoteDataSource = ref.watch(readerRemoteDataSourceProvider);

  return ReaderRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
}
