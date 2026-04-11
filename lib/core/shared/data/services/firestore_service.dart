import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/error/exceptions.dart';
import 'connectivity_service.dart';

class FirestoreService {
  FirestoreService({
    required ConnectivityService connectivityService,
    required FirebaseFirestore firebaseFirestore,
  }) : _connectivityService = connectivityService,
       _firebaseFirestore = firebaseFirestore;

  final ConnectivityService _connectivityService;
  final FirebaseFirestore _firebaseFirestore;

  FirebaseFirestore get firebaseFirestore => _firebaseFirestore;

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      firebaseFirestore.collection(path);

  String generateId(String collectionPath) => collection(collectionPath).doc().id;

  Future<void> requireConnectivity() async {
    if (!await _connectivityService.isConnected()) {
      throw const NoConnectionException(
        'Cannot perform this operation while offline. Please check your internet connection and try again.',
      );
    }
  }

  Future<List<QueryDocumentSnapshot<T>>> safeGetDocs<T>(Query<T> query) async {
    try {
      return (await query.get()).docs;
    } catch (_) {
      try {
        return (await query.get(const GetOptions(source: Source.cache))).docs;
      } catch (_) {
        return <QueryDocumentSnapshot<T>>[];
      }
    }
  }

  Future<DocumentSnapshot<T>?> safeGetDoc<T>(DocumentReference<T> doc) async {
    try {
      return await doc.get();
    } catch (_) {
      try {
        return await doc.get(const GetOptions(source: Source.cache));
      } catch (_) {
        return null;
      }
    }
  }
}
