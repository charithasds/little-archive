import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/error/exceptions.dart';
import 'connectivity_service.dart';

class FirestoreService {
  FirestoreService({required ConnectivityService connectivityService})
    : _connectivityService = connectivityService;

  final ConnectivityService _connectivityService;

  FirebaseFirestore get instance => FirebaseFirestore.instance;

  Future<void> requireConnectivity() async {
    final bool isConnected = await _connectivityService.isConnected();

    if (!isConnected) {
      throw const NoConnectionException(
        'Cannot perform this operation while offline. Please check your internet connection and try again.',
      );
    }
  }

  Future<List<QueryDocumentSnapshot<T>>> safeGetDocs<T>(Query<T> query) async {
    try {
      final QuerySnapshot<T> snapshot = await query.get();

      return snapshot.docs;
    } catch (e) {
      try {
        final QuerySnapshot<T> snapshot = await query.get(const GetOptions(source: Source.cache));

        return snapshot.docs;
      } catch (_) {
        return <QueryDocumentSnapshot<T>>[];
      }
    }
  }

  Future<DocumentSnapshot<T>?> safeGetDoc<T>(DocumentReference<T> doc) async {
    try {
      final DocumentSnapshot<T> snapshot = await doc.get();

      return snapshot;
    } catch (e) {
      try {
        final DocumentSnapshot<T> snapshot = await doc.get(const GetOptions(source: Source.cache));

        return snapshot;
      } catch (_) {
        return null;
      }
    }
  }
}
