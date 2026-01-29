import 'package:cloud_firestore/cloud_firestore.dart';
import '../error/exceptions.dart';
import '../network/connectivity_service.dart';

/// Helper class to handle Firestore operations gracefully, with offline fallback.
/// It catches network-related errors and returns safe defaults (empty lists or null)
/// to prevent the application from crashing when offline and cache is unavailable.
///
/// For CUD (Create, Update, Delete) operations, use [requireConnectivity] to ensure
/// network is available before attempting the operation.
class FirestoreUtils {
  static final ConnectivityService _connectivityService = ConnectivityService();

  /// Checks if the device has an active network connection.
  /// Throws [NoConnectionException] if offline.
  ///
  /// Call this method at the start of any CUD operation to prevent
  /// offline modifications that could lead to data inconsistencies.
  static Future<void> requireConnectivity() async {
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw const NoConnectionException(
        'Cannot perform this operation while offline. Please check your internet connection and try again.',
      );
    }
  }

  /// Attempts to fetch a query from the server.
  /// If it fails (e.g. network error), attempts to fetch from cache.
  /// If that also fails, returns an empty list.
  static Future<List<QueryDocumentSnapshot<T>>> safeGetDocs<T>(
    Query<T> query,
  ) async {
    try {
      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e) {
      // If server fetch fails, try cache
      try {
        final snapshot = await query.get(
          const GetOptions(source: Source.cache),
        );
        return snapshot.docs;
      } catch (_) {
        // If cache also fails, return empty list instead of crashing
        return [];
      }
    }
  }

  /// Attempts to fetch a document from the server.
  /// If it fails (e.g. network error), attempts to fetch from cache.
  /// If that also fails, returns null.
  static Future<DocumentSnapshot<T>?> safeGetDoc<T>(
    DocumentReference<T> doc,
  ) async {
    try {
      return await doc.get();
    } catch (e) {
      // If server fetch fails, try cache
      try {
        return await doc.get(const GetOptions(source: Source.cache));
      } catch (_) {
        // If cache also fails, return null instead of crashing
        return null;
      }
    }
  }
}
