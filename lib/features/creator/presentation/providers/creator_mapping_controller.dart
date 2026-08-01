import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/creator_remote_datasource.dart';
import '../../domain/entities/creator_entity.dart';
import '../../domain/usecases/fetch_unmapped_translators_usecase.dart';
import '../../domain/usecases/map_translator_to_creator_usecase.dart';

part 'creator_mapping_controller.g.dart';

@riverpod
class CreatorMappingController extends _$CreatorMappingController {
  @override
  FutureOr<List<CreatorEntity>> build() async => ref.read(fetchUnmappedTranslatorsUseCaseProvider).call();

  Future<void> mapTranslator(String translatorId, String creatorId) async {
    state = const AsyncValue<List<CreatorEntity>>.loading();
    try {
      await ref.read(mapTranslatorToCreatorUseCaseProvider).call(
        translatorId: translatorId,
        creatorId: creatorId,
      );
      // Reload the list of unmapped translators
      state = AsyncValue<List<CreatorEntity>>.data(
        await ref.read(fetchUnmappedTranslatorsUseCaseProvider).call(),
      );
    } catch (e, stack) {
      state = AsyncValue<List<CreatorEntity>>.error(e, stack);
    }
  }

  Future<void> keepTranslatorAsIs(String translatorId) async {
    state = const AsyncValue<List<CreatorEntity>>.loading();
    try {
      await ref.read(creatorRemoteDataSourceProvider).keepTranslatorAsIs(translatorId);
      // Reload the list of unmapped translators
      state = AsyncValue<List<CreatorEntity>>.data(
        await ref.read(fetchUnmappedTranslatorsUseCaseProvider).call(),
      );
    } catch (e, stack) {
      state = AsyncValue<List<CreatorEntity>>.error(e, stack);
    }
  }
}
