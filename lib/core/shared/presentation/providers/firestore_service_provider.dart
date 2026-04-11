import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/services/connectivity_service.dart';
import '../../data/services/firestore_service.dart';
import 'connectivity_provider.dart';
import 'firebase_provider.dart';

part 'firestore_service_provider.g.dart';

@riverpod
FirestoreService firestoreService(Ref ref) {
  final ConnectivityService connectivityService = ref.watch(connectivityServiceProvider);
  final FirebaseFirestore firebaseFirestore = ref.watch(firebaseFirestoreProvider);

  return FirestoreService(
    connectivityService: connectivityService,
    firebaseFirestore: firebaseFirestore,
  );
}
