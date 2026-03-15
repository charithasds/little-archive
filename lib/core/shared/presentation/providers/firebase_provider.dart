import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Exposes the singleton [FirebaseApp] instance.
/// Firebase must be initialized (via [initializationProvider]) before this is accessed.
final Provider<FirebaseApp> firebaseAppProvider = Provider<FirebaseApp>(
  (Ref ref) => Firebase.app(),
);

/// Exposes the [FirebaseAuth] singleton.
final Provider<FirebaseAuth> firebaseAuthProvider = Provider<FirebaseAuth>(
  (Ref ref) => FirebaseAuth.instance,
);
