import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/creator_remote_datasource.dart';
import '../../data/models/creator_model.dart';
import '../entities/creator_entity.dart';

part 'fetch_unmapped_translators_usecase.g.dart';

class FetchUnmappedTranslatorsUseCase {
  const FetchUnmappedTranslatorsUseCase(this.remoteDataSource);

  final CreatorRemoteDataSource remoteDataSource;

  Future<List<CreatorEntity>> call() async {
    final List<CreatorModel> models = await remoteDataSource.fetchUnmappedTranslators();
    return models.map((CreatorModel model) => CreatorEntity(
      id: model.id,
      name: model.name,
      image: model.image,
      otherName: model.otherName,
      website: model.website,
      facebook: model.facebook,
      authoredBookIds: model.authoredBookIds,
      translatedBookIds: model.translatedBookIds,
      authoredWorkIds: model.authoredWorkIds,
      translatedWorkIds: model.translatedWorkIds,
      createdDate: model.createdDate,
      lastUpdated: model.lastUpdated,
    )).toList();
  }
}

@riverpod
FetchUnmappedTranslatorsUseCase fetchUnmappedTranslatorsUseCase(Ref ref) => FetchUnmappedTranslatorsUseCase(
    ref.watch(creatorRemoteDataSourceProvider),
  );
