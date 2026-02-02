import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/firestore_utils.dart';
import '../models/translator_model.dart';

abstract class TranslatorRemoteDataSource {
  Future<List<TranslatorModel>> getTranslators(String userId);
  Future<TranslatorModel?> getTranslatorById(String id);
  Future<void> addTranslator(TranslatorModel translator);
  Future<void> updateTranslator(TranslatorModel translator);
  Future<void> deleteTranslator(String id);
  Stream<List<TranslatorModel>> watchTranslators(String userId);
}

class TranslatorRemoteDataSourceImpl implements TranslatorRemoteDataSource {

  TranslatorRemoteDataSourceImpl({required this.firestore});
  final FirebaseFirestore firestore;
  final String collectionPath = 'translators';

  @override
  Future<List<TranslatorModel>> getTranslators(String userId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await FirestoreUtils.safeGetDocs(
      firestore.collection(collectionPath).where('userId', isEqualTo: userId),
    );
    return docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => TranslatorModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<TranslatorModel?> getTranslatorById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc = await FirestoreUtils.safeGetDoc(
      firestore.collection(collectionPath).doc(id),
    );
    if (doc == null || !doc.exists) {
      return null;
    }
    return TranslatorModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addTranslator(TranslatorModel translator) async {
    await FirestoreUtils.requireConnectivity();
    await firestore
        .collection(collectionPath)
        .doc(translator.id.isEmpty ? null : translator.id)
        .set(translator.toMap());
  }

  @override
  Future<void> updateTranslator(TranslatorModel translator) async {
    await FirestoreUtils.requireConnectivity();
    await firestore
        .collection(collectionPath)
        .doc(translator.id)
        .update(translator.toMap());
  }

  @override
  Future<void> deleteTranslator(String id) async {
    await FirestoreUtils.requireConnectivity();
    await firestore.collection(collectionPath).doc(id).delete();
  }

  @override
  Stream<List<TranslatorModel>> watchTranslators(String userId) {
    return firestore
        .collection(collectionPath)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => TranslatorModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}
