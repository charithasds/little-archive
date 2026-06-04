import '../entities/translator_entity.dart';

abstract class TranslatorRepository {
  String generateId();
  Future<List<TranslatorEntity>> fetchTranslators();
  Future<TranslatorEntity?> fetchTranslatorById(String id);
  Stream<List<TranslatorEntity>> watchTranslators();
  Future<void> addTranslator(TranslatorEntity translator);
  Future<void> editTranslator(TranslatorEntity translator, {TranslatorEntity? oldTranslator});
  Future<void> removeTranslator(String id);
}
