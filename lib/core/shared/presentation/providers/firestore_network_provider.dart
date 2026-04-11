import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'connectivity_provider.dart';
import 'firebase_provider.dart';
import 'initialization_provider.dart';

part 'firestore_network_provider.g.dart';

@Riverpod(keepAlive: true)
class FirestoreNetwork extends _$FirestoreNetwork {
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

  void handleLifecyclePaused() {
    final AsyncValue<void> init = ref.read(initializationProvider);

    if (init is AsyncData) {
      ref.read(firebaseFirestoreProvider).disableNetwork();
    }
  }

  void handleLifecycleResumed() {
    final AsyncValue<void> init = ref.read(initializationProvider);

    if (init is AsyncData && state) {
      ref.read(firebaseFirestoreProvider).enableNetwork();
    }
  }
}
