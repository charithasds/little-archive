import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/creator_remote_datasource.dart';

part 'map_translator_to_creator_usecase.g.dart';

class MapTranslatorToCreatorUseCase {
  const MapTranslatorToCreatorUseCase(this.remoteDataSource);

  final CreatorRemoteDataSource remoteDataSource;

  Future<void> call({required String translatorId, required String creatorId}) async {
    await remoteDataSource.mapTranslatorToCreator(translatorId, creatorId);
  }
}

@riverpod
MapTranslatorToCreatorUseCase mapTranslatorToCreatorUseCase(Ref ref) => MapTranslatorToCreatorUseCase(
    ref.watch(creatorRemoteDataSourceProvider),
  );
