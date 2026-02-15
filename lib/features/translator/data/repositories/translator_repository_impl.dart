import '../../domain/entities/translator_entity.dart';
import '../../domain/repositories/translator_repository.dart';
import '../datasources/translator_remote_datasource.dart';
import '../models/translator_model.dart';

class TranslatorRepositoryImpl implements TranslatorRepository {
  TranslatorRepositoryImpl({required this.remoteDataSource});
  final TranslatorRemoteDataSource remoteDataSource;

  @override
  Future<List<TranslatorEntity>> getTranslators(String userId) =>
      remoteDataSource.getTranslators(userId);

  @override
  Future<TranslatorEntity?> getTranslatorById(String id) => remoteDataSource.getTranslatorById(id);

  @override
  Future<void> addTranslator(TranslatorEntity translator) => remoteDataSource.addTranslator(
    TranslatorModel(
      id: translator.id,
      userId: translator.userId,
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

  @override
  Future<void> updateTranslator(TranslatorEntity translator) => remoteDataSource.updateTranslator(
    TranslatorModel(
      id: translator.id,
      userId: translator.userId,
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

  @override
  Future<void> deleteTranslator(String id) => remoteDataSource.deleteTranslator(id);

  @override
  Stream<List<TranslatorEntity>> watchTranslators(String userId) =>
      remoteDataSource.watchTranslators(userId);
}
