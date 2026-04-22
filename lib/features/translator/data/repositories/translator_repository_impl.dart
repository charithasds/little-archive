import '../../../../core/shared/data/services/relationship_sync_service.dart';
import '../../domain/entities/translator_entity.dart';
import '../../domain/repositories/translator_repository.dart';
import '../datasources/translator_remote_datasource.dart';
import '../models/translator_model.dart';

class TranslatorRepositoryImpl implements TranslatorRepository {
  TranslatorRepositoryImpl({required this.remoteDataSource, required this.relationshipSyncService});

  final TranslatorRemoteDataSource remoteDataSource;
  final RelationshipSyncService relationshipSyncService;

  @override
  String generateId() => remoteDataSource.generateId();

  @override
  Future<List<TranslatorEntity>> getTranslators() => remoteDataSource.fetchTranslators();

  @override
  Future<TranslatorEntity?> getTranslatorById(String id) =>
      remoteDataSource.fetchTranslatorById(id);

  @override
  Stream<List<TranslatorEntity>> watchTranslators() => remoteDataSource.watchTranslators();

  @override
  Future<void> addTranslator(TranslatorEntity translator) async {
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
    );

    await relationshipSyncService.syncTranslatorRelationships(
      translatorId: translator.id,
      newBookIds: translator.bookIds,
      newWorkIds: translator.workIds,
    );
  }

  @override
  Future<void> editTranslator(TranslatorEntity translator) async {
    final TranslatorModel? existingTranslator = await remoteDataSource.fetchTranslatorById(
      translator.id,
    );

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
    );

    await relationshipSyncService.syncTranslatorRelationships(
      translatorId: translator.id,
      newBookIds: translator.bookIds,
      newWorkIds: translator.workIds,
      oldBookIds: existingTranslator?.bookIds ?? <String>[],
      oldWorkIds: existingTranslator?.workIds ?? <String>[],
    );
  }

  @override
  Future<void> removeTranslator(String id) async {
    final TranslatorModel? existingTranslator = await remoteDataSource.fetchTranslatorById(id);

    if (existingTranslator != null) {
      await relationshipSyncService.removeTranslatorRelationships(
        translatorId: id,
        bookIds: existingTranslator.bookIds,
        workIds: existingTranslator.workIds,
      );
    }

    await remoteDataSource.removeTranslator(id);
  }
}
