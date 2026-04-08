import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity_provider.dart';
import 'firebase_provider.dart';
import 'initialization_provider.dart';

/// [FirestoreNetworkNotifier] manages the online/offline state of your Firestore instance.
/// It automatically disables the network when offline or in the background to save resources.
class FirestoreNetworkNotifier extends Notifier<bool> {
  @override
  bool build() {
    final AsyncValue<void> init = ref.watch(initializationProvider);
    final AsyncValue<bool> connectivity = ref.watch(connectivityStreamProvider);
    final FirebaseFirestore firebaseFirestore;
    final bool isConnected;

    if (!init.hasValue) {
      return true;
    }

    isConnected = connectivity.asData?.value ?? true;
    firebaseFirestore = ref.watch(firebaseFirestoreProvider);

    if (isConnected) {
      firebaseFirestore.enableNetwork();
    } else {
      firebaseFirestore.disableNetwork();
    }

    return isConnected;
  }

  /// Disables Firestore network when the app is minimized (paused).
  void handleLifecyclePaused() {
    final AsyncValue<void> init = ref.read(initializationProvider);

    if (init is AsyncData) {
      ref.read(firebaseFirestoreProvider).disableNetwork();
    }
  }

  /// Re-enables Firestore network when the app returns to the foreground (resumed).
  void handleLifecycleResumed() {
    final AsyncValue<void> init = ref.read(initializationProvider);

    if (init is AsyncData && state) {
      ref.read(firebaseFirestoreProvider).enableNetwork();
    }
  }
}

/// Provides the [FirestoreNetworkNotifier] to automatically sync Firestore network state.
final NotifierProvider<FirestoreNetworkNotifier, bool> firestoreNetworkProvider =
    NotifierProvider<FirestoreNetworkNotifier, bool>(FirestoreNetworkNotifier.new);
