import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/error/exceptions.dart';
import '../../presentation/providers/firebase_provider.dart';
import 'connectivity_service.dart';

part 'firestore_service.g.dart';

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

@riverpod
FirestoreService firestoreService(Ref ref) {
  final ConnectivityService connectivityService = ref.watch(connectivityServiceProvider);
  final FirebaseFirestore firebaseFirestore = ref.watch(firebaseFirestoreProvider);

  return FirestoreService(
    connectivityService: connectivityService,
    firebaseFirestore: firebaseFirestore,
  );
}
