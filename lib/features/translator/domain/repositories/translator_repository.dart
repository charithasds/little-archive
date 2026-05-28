import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/translator_entity.dart';

abstract class TranslatorRepository {
  String generateId();
  Future<List<TranslatorEntity>> fetchTranslators();
  Future<TranslatorEntity?> fetchTranslatorById(String id);
  Stream<List<TranslatorEntity>> watchTranslators();
  Future<void> addTranslator(TranslatorEntity translator, {WriteBatch? batch});
  Future<void> editTranslator(TranslatorEntity translator, {TranslatorEntity? oldTranslator, WriteBatch? batch});
  Future<void> removeTranslator(String id, {WriteBatch? batch});
}
