import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/connectivity_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/relationship_sync_service.dart';
import 'connectivity_provider.dart';

final Provider<FirestoreService> firestoreServiceProvider = Provider<FirestoreService>((Ref ref) {
  final ConnectivityService connectivityService = ref.watch(connectivityServiceProvider);

  return FirestoreService(connectivityService: connectivityService);
});

final Provider<FirebaseFirestore> firestoreProvider = Provider<FirebaseFirestore>(
  (Ref ref) => ref.watch(firestoreServiceProvider).instance,
);

final Provider<RelationshipSyncService> relationshipSyncServiceProvider =
    Provider<RelationshipSyncService>((Ref ref) {
      final FirebaseFirestore firestore = ref.watch(firestoreProvider);

      return RelationshipSyncService(firestore: firestore);
    });

class FirestoreNetworkNotifier extends Notifier<bool> {
  @override
  bool build() {
    final AsyncValue<bool> connectivityAsync = ref.watch(connectivityStreamProvider);
    final FirebaseFirestore firebaseFirestore = ref.watch(firestoreProvider);

    connectivityAsync.whenData((bool isConnected) {
      if (isConnected != state) {
        state = isConnected;

        if (isConnected) {
          firebaseFirestore.enableNetwork();
        } else {
          firebaseFirestore.disableNetwork();
        }
      }
    });

    return true;
  }

  void handleLifecycleResumed() {
    if (state) {
      try {
        ref.read(firestoreProvider).enableNetwork();
      } catch (_) {}
    }
  }

  void handleLifecyclePaused() {
    try {
      ref.read(firestoreProvider).disableNetwork();
    } catch (_) {}
  }
}

final NotifierProvider<FirestoreNetworkNotifier, bool> firestoreNetworkProvider =
    NotifierProvider<FirestoreNetworkNotifier, bool>(FirestoreNetworkNotifier.new);
