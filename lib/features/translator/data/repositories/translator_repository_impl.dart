import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../domain/entities/translator_entity.dart';
import '../../domain/repositories/translator_repository.dart';
import '../datasources/translator_remote_datasource.dart';
import '../models/translator_model.dart';

part 'translator_repository_impl.g.dart';

class TranslatorRepositoryImpl implements TranslatorRepository {
  TranslatorRepositoryImpl({required this.remoteDataSource, required this.relationshipSyncService});

  final TranslatorRemoteDataSource remoteDataSource;
  final RelationshipSyncService relationshipSyncService;

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<TranslatorEntity>> fetchTranslators() => remoteDataSource.fetchTranslators();

  @override
  Future<TranslatorEntity?> fetchTranslatorById(String id) =>
      remoteDataSource.fetchTranslatorById(id);

  @override
  Stream<List<TranslatorEntity>> watchTranslators() => remoteDataSource.watchTranslators();

  @override
  Future<void> addTranslator(TranslatorEntity translator, {WriteBatch? batch}) async {
    await remoteDataSource.addTranslator(
      TranslatorModel(
        id: translator.id,
        name: translator.name,
        image: translator.image,
        otherName: translator.otherName,
        website: translator.website,
        facebook: translator.facebook,
        bookIds: translator.bookIds,
        workIds: translator.workIds,
        createdDate: translator.createdDate,
        lastUpdated: translator.lastUpdated,
      ),
      batch: batch,
    );

    await relationshipSyncService.syncTranslatorRelationships(
      translatorId: translator.id,
      newBookIds: translator.bookIds,
      newWorkIds: translator.workIds,
      batch: batch,
    );
  }

  @override
  Future<void> editTranslator(TranslatorEntity translator, {TranslatorEntity? oldTranslator, WriteBatch? batch}) async {
    final List<String> oldBookIds;
    final List<String> oldWorkIds;

    if (oldTranslator != null) {
      oldBookIds = oldTranslator.bookIds;
      oldWorkIds = oldTranslator.workIds;
    } else {
      final TranslatorModel? existingTranslator = await remoteDataSource.fetchTranslatorById(
        translator.id,
      );
      oldBookIds = existingTranslator?.bookIds ?? <String>[];
      oldWorkIds = existingTranslator?.workIds ?? <String>[];
    }

    await remoteDataSource.editTranslator(
      TranslatorModel(
        id: translator.id,
        name: translator.name,
        image: translator.image,
        otherName: translator.otherName,
        website: translator.website,
        facebook: translator.facebook,
        bookIds: translator.bookIds,
        workIds: translator.workIds,
        createdDate: translator.createdDate,
        lastUpdated: translator.lastUpdated,
      ),
      batch: batch,
    );

    await relationshipSyncService.syncTranslatorRelationships(
      translatorId: translator.id,
      newBookIds: translator.bookIds,
      newWorkIds: translator.workIds,
      oldBookIds: oldBookIds,
      oldWorkIds: oldWorkIds,
      batch: batch,
    );
  }

  @override
  Future<void> removeTranslator(String id, {WriteBatch? batch}) async {
    final TranslatorModel? existingTranslator = await remoteDataSource.fetchTranslatorById(id);

    if (existingTranslator != null) {
      await relationshipSyncService.removeTranslatorRelationships(
        translatorId: id,
        bookIds: existingTranslator.bookIds,
        workIds: existingTranslator.workIds,
        batch: batch,
      );
    }

    await remoteDataSource.removeTranslator(id, batch: batch);
  }
}

@riverpod
TranslatorRepository translatorRepository(Ref ref) {
  final TranslatorRemoteDataSource remoteDataSource = ref.watch(translatorRemoteDataSourceProvider);
  final RelationshipSyncService relationshipSyncService = ref.watch(
    relationshipSyncServiceProvider,
  );

  return TranslatorRepositoryImpl(
    remoteDataSource: remoteDataSource,
    relationshipSyncService: relationshipSyncService,
  );
}
