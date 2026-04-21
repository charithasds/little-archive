import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/shared/data/services/firestore_service.dart';
import '../models/translator_model.dart';

abstract class TranslatorRemoteDataSource {
  String generateId();

  Future<List<TranslatorModel>> fetchTranslators();
  Future<TranslatorModel?> fetchTranslatorById(String id);
  Stream<List<TranslatorModel>> watchTranslators();
  Future<void> addTranslator(TranslatorModel translator);
  Future<void> editTranslator(TranslatorModel translator);
  Future<void> removeTranslator(String id);
}

class TranslatorRemoteDataSourceImpl implements TranslatorRemoteDataSource {
  TranslatorRemoteDataSourceImpl({required this.firestoreService, required this.userId});

  final FirestoreService firestoreService;
  final String userId;

  FirebaseFirestore get _firestore => firestoreService.firebaseFirestore;
  String get _collectionPath => 'users/$userId/translators';

  @override
  String generateId() => firestoreService.generateId('translators');

  @override
  Future<List<TranslatorModel>> fetchTranslators() async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
        await firestoreService.safeGetDocs(_firestore.collection(_collectionPath));

    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              TranslatorModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<TranslatorModel?> fetchTranslatorById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc =
        await firestoreService.safeGetDoc(_firestore.collection(_collectionPath).doc(id));

    if (doc == null || !doc.exists) {
      return null;
    }

    return TranslatorModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Stream<List<TranslatorModel>> watchTranslators() => _firestore
      .collection(_collectionPath)
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  TranslatorModel.fromMap(doc.data(), doc.id),
            )
            .toList(),
      );

  @override
  Future<void> addTranslator(TranslatorModel translator) async {
    await firestoreService.requireConnectivity();
    await _firestore
        .collection(_collectionPath)
        .doc(translator.id.isEmpty ? null : translator.id)
        .set(translator.toMap());
  }

  @override
  Future<void> editTranslator(TranslatorModel translator) async {
    await firestoreService.requireConnectivity();
    await _firestore.collection(_collectionPath).doc(translator.id).update(translator.toMap());
  }

  @override
  Future<void> removeTranslator(String id) async {
    await firestoreService.requireConnectivity();
    await _firestore.collection(_collectionPath).doc(id).delete();
  }
}
