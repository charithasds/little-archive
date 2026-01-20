import '../datasources/translator_remote_datasource.dart';
import '../../domain/entities/translator_entity.dart';
import '../../domain/repositories/translator_repository.dart';
import '../models/translator_model.dart';

class TranslatorRepositoryImpl implements TranslatorRepository {
  final TranslatorRemoteDataSource remoteDataSource;

  TranslatorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TranslatorEntity>> getTranslators() =>
      remoteDataSource.getTranslators();

  @override
  Future<TranslatorEntity?> getTranslatorById(String id) =>
      remoteDataSource.getTranslatorById(id);

  @override
  Future<void> addTranslator(TranslatorEntity translator) {
    return remoteDataSource.addTranslator(
      TranslatorModel(
        id: translator.id,
        name: translator.name,
        image: translator.image,
        otherName: translator.otherName,
        website: translator.website,
        facebook: translator.facebook,
        bookIds: translator.bookIds,
        shortIds: translator.shortIds,
      ),
    );
  }

  @override
  Future<void> updateTranslator(TranslatorEntity translator) {
    return remoteDataSource.updateTranslator(
      TranslatorModel(
        id: translator.id,
        name: translator.name,
        image: translator.image,
        otherName: translator.otherName,
        website: translator.website,
        facebook: translator.facebook,
        bookIds: translator.bookIds,
        shortIds: translator.shortIds,
      ),
    );
  }

  @override
  Future<void> deleteTranslator(String id) =>
      remoteDataSource.deleteTranslator(id);

  @override
  Stream<List<TranslatorEntity>> watchTranslators() =>
      remoteDataSource.watchTranslators();
}
