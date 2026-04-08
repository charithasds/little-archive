import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/error/exceptions.dart';
import 'connectivity_service.dart';

/// A utility service that wraps [FirebaseFirestore] to provide safer data fetching,
/// connectivity checks, and ID generation.
class FirestoreService {
  /// Creates a [FirestoreService].
  FirestoreService({
    required ConnectivityService connectivityService,
    required FirebaseFirestore firebaseFirestore,
  }) : _connectivityService = connectivityService,
       _firebaseFirestore = firebaseFirestore;

  final ConnectivityService _connectivityService;
  final FirebaseFirestore _firebaseFirestore;

  /// Returns the underlying [FirebaseFirestore] instance.
  FirebaseFirestore get firebaseFirestore => _firebaseFirestore;

  /// Returns a [CollectionReference] for the given [path].
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      firebaseFirestore.collection(path);

  /// Generates a unique ID for a document in the specified [collectionPath].
  String generateId(String collectionPath) => collection(collectionPath).doc().id;

  /// Throws a [NoConnectionException] if the device is not currently connected to the internet.
  /// Useful for guarding write operations.
  Future<void> requireConnectivity() async {
    if (!await _connectivityService.isConnected()) {
      throw const NoConnectionException(
        'Cannot perform this operation while offline. Please check your internet connection and try again.',
      );
    }
  }

  /// Safely fetches documents for a given [query].
  /// If the initial network fetch fails, it attempts to retrieve results from the local cache.
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

  /// Safely fetches a single document from a [doc] reference.
  /// If the initial network fetch fails, it attempts to retrieve the document from the local cache.
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
