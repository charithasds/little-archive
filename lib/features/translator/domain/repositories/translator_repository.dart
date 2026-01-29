import '../entities/translator_entity.dart';

abstract class TranslatorRepository {
  Future<List<TranslatorEntity>> getTranslators(String userId);
  Future<TranslatorEntity?> getTranslatorById(String id);
  Future<void> addTranslator(TranslatorEntity translator);
  Future<void> updateTranslator(TranslatorEntity translator);
  Future<void> deleteTranslator(String id);
  Stream<List<TranslatorEntity>> watchTranslators(String userId);
}
