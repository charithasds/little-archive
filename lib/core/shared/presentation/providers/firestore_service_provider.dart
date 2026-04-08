import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/connectivity_service.dart';
import '../../data/services/firestore_service.dart';
import 'connectivity_provider.dart';
import 'firebase_provider.dart';

/// Provides the [FirestoreService] which handles basic database interactions.
final Provider<FirestoreService> firestoreServiceProvider = Provider<FirestoreService>((Ref ref) {
  final ConnectivityService connectivityService = ref.watch(connectivityServiceProvider);
  final FirebaseFirestore firebaseFirestore = ref.watch(firebaseFirestoreProvider);

  return FirestoreService(
    connectivityService: connectivityService,
    firebaseFirestore: firebaseFirestore,
  );
});
