import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/error/exceptions.dart';
import 'initialization_provider.dart';

/// Provides the raw [FirebaseAuth] instance from the Firebase SDK.
/// This provider ensures Firebase is initialized before returning the instance.
final Provider<FirebaseAuth> firebaseAuthProvider = Provider<FirebaseAuth>((Ref ref) {
  final AsyncValue<void> init = ref.watch(initializationProvider);

  if (!init.hasValue || init.hasError) {
    throw const InitializationException('Firebase has not been initialized yet.');
  }

  return FirebaseAuth.instance;
});

/// Provides the raw [FirebaseFirestore] instance from the Firebase SDK.
/// This provider ensures Firebase is initialized before returning the instance.
final Provider<FirebaseFirestore> firebaseFirestoreProvider = Provider<FirebaseFirestore>((
  Ref ref,
) {
  final AsyncValue<void> init = ref.watch(initializationProvider);

  if (!init.hasValue || init.hasError) {
    throw const InitializationException('Firebase has not been initialized yet.');
  }

  return FirebaseFirestore.instance;
});
