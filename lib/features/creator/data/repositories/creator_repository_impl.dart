import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/shared/presentation/utils/images.dart';
import '../../domain/entities/creator_entity.dart';
import '../../domain/repositories/creator_repository.dart';
import '../datasources/creator_remote_datasource.dart';
import '../models/creator_model.dart';

part 'creator_repository_impl.g.dart';

class CreatorRepositoryImpl implements CreatorRepository {
  CreatorRepositoryImpl({required this.remoteDataSource});

  final CreatorRemoteDataSource remoteDataSource;

  final Set<String> _processedImageCreatorIds = <String>{};

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<CreatorEntity>> fetchCreators() async {
    final List<CreatorEntity> creators = await remoteDataSource.fetchCreators();
    _compressExistingLargeImages(creators);
    return creators;
  }

  void _compressExistingLargeImages(List<CreatorEntity> creators) {
    Future<void>.microtask(() async {
      for (final CreatorEntity creator in creators) {
        if (_processedImageCreatorIds.contains(creator.id)) {
          continue;
        }
        _processedImageCreatorIds.add(creator.id);

        final String? image = creator.image;
        if (image != null && image.length > 50000) {
          final String? compressed = Images.compressImageIfNeeded(image);
          if (compressed != null && compressed != image) {
            final CreatorEntity updated = creator.copyWith(
              image: Nullable<String?>(compressed),
              lastUpdated: DateTime.now(),
            );
            await editCreator(updated);
          }
        }
      }
    });
  }

  @override
  Future<CreatorEntity?> fetchCreatorById(String id) => remoteDataSource.fetchCreatorById(id);

  @override
  Stream<List<CreatorEntity>> watchCreators() => remoteDataSource.watchCreators();

  @override
  Future<void> addCreator(CreatorEntity creator) async {
    await remoteDataSource.addCreator(
      CreatorModel(
        id: creator.id,
        name: creator.name,
        image: Images.compressImageIfNeeded(creator.image),
        otherName: creator.otherName,
        website: creator.website,
        facebook: creator.facebook,

        authoredBookIds: creator.authoredBookIds,
        translatedBookIds: creator.translatedBookIds,
        authoredWorkIds: creator.authoredWorkIds,
        translatedWorkIds: creator.translatedWorkIds,
        createdDate: creator.createdDate,
        lastUpdated: creator.lastUpdated,
      ),
    );
  }

  @override
  Future<void> editCreator(CreatorEntity creator, {CreatorEntity? oldCreator}) async {
    await remoteDataSource.editCreator(
      CreatorModel(
        id: creator.id,
        name: creator.name,
        image: Images.compressImageIfNeeded(creator.image),
        otherName: creator.otherName,
        website: creator.website,
        facebook: creator.facebook,

        authoredBookIds: creator.authoredBookIds,
        translatedBookIds: creator.translatedBookIds,
        authoredWorkIds: creator.authoredWorkIds,
        translatedWorkIds: creator.translatedWorkIds,
        createdDate: creator.createdDate,
        lastUpdated: creator.lastUpdated,
      ),
    );
  }

  @override
  Future<void> removeCreator(String id) async {
    await remoteDataSource.removeCreator(id);
  }

  @override
  Future<void> mergeCreators(String targetId, String sourceId) async {
    await remoteDataSource.mergeCreators(targetId, sourceId);
  }
}

@riverpod
CreatorRepository creatorRepository(Ref ref) {
  final CreatorRemoteDataSource remoteDataSource = ref.watch(creatorRemoteDataSourceProvider);

  return CreatorRepositoryImpl(remoteDataSource: remoteDataSource);
}
