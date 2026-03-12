import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/shared/data/services/firestore_service.dart';
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
  TranslatorRemoteDataSourceImpl({required this.firestoreService});
  final FirestoreService firestoreService;

  FirebaseFirestore get firestore => firestoreService.instance;

  String get _currentUserId {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to perform this operation.');
    }
    return user.uid;
  }

  String collectionPath(String uid) => 'users/$uid/translators';

  @override
  Future<List<TranslatorModel>> getTranslators(String userId) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = await firestoreService
        .safeGetDocs(firestore.collection(collectionPath(userId)));
    return docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              TranslatorModel.fromMap(doc.data(), doc.id),
        )
        .toList();
  }

  @override
  Future<TranslatorModel?> getTranslatorById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>>? doc = await firestoreService.safeGetDoc(
      firestore.collection(collectionPath(_currentUserId)).doc(id),
    );
    if (doc == null || !doc.exists) {
      return null;
    }
    return TranslatorModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addTranslator(TranslatorModel translator) async {
    await firestoreService.requireConnectivity();
    await firestore
        .collection(collectionPath(_currentUserId))
        .doc(translator.id.isEmpty ? null : translator.id)
        .set(translator.toMap());
  }

  @override
  Future<void> updateTranslator(TranslatorModel translator) async {
    await firestoreService.requireConnectivity();
    await firestore
        .collection(collectionPath(_currentUserId))
        .doc(translator.id)
        .update(translator.toMap());
  }

  @override
  Future<void> deleteTranslator(String id) async {
    await firestoreService.requireConnectivity();
    await firestore.collection(collectionPath(_currentUserId)).doc(id).delete();
  }

  @override
  Stream<List<TranslatorModel>> watchTranslators(String userId) => firestore
      .collection(collectionPath(userId))
      .snapshots()
      .map(
        (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  TranslatorModel.fromMap(doc.data(), doc.id),
            )
            .toList(),
      );
}
