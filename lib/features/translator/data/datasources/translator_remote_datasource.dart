import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/translator_model.dart';

abstract class TranslatorRemoteDataSource {
  Future<List<TranslatorModel>> getTranslators();
  Future<TranslatorModel?> getTranslatorById(String id);
  Future<void> addTranslator(TranslatorModel translator);
  Future<void> updateTranslator(TranslatorModel translator);
  Future<void> deleteTranslator(String id);
  Stream<List<TranslatorModel>> watchTranslators();
}

class TranslatorRemoteDataSourceImpl implements TranslatorRemoteDataSource {
  final FirebaseFirestore firestore;
  final String collectionPath = 'translators';

  TranslatorRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<TranslatorModel>> getTranslators() async {
    final snapshot = await firestore.collection(collectionPath).get();
    return snapshot.docs
        .map((doc) => TranslatorModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<TranslatorModel?> getTranslatorById(String id) async {
    final doc = await firestore.collection(collectionPath).doc(id).get();
    if (!doc.exists) return null;
    return TranslatorModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addTranslator(TranslatorModel translator) async {
    await firestore
        .collection(collectionPath)
        .doc(translator.id.isEmpty ? null : translator.id)
        .set(translator.toMap());
  }

  @override
  Future<void> updateTranslator(TranslatorModel translator) async {
    await firestore
        .collection(collectionPath)
        .doc(translator.id)
        .update(translator.toMap());
  }

  @override
  Future<void> deleteTranslator(String id) async {
    await firestore.collection(collectionPath).doc(id).delete();
  }

  @override
  Stream<List<TranslatorModel>> watchTranslators() {
    return firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TranslatorModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
