import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/error/exceptions.dart';
import 'initialization_provider.dart';

part 'firebase_provider.g.dart';

@riverpod
FirebaseAuth firebaseAuth(Ref ref) {
  final AsyncValue<void> init = ref.watch(initializationProvider);

  if (!init.hasValue || init.hasError) {
    throw const InitializationException('Firebase has not been initialized yet.');
  }

  return FirebaseAuth.instance;
}

final Provider<FirebaseFirestore> firebaseFirestoreProvider = Provider<FirebaseFirestore>((
  Ref ref,
) {
  final AsyncValue<void> init = ref.watch(initializationProvider);

  if (!init.hasValue || init.hasError) {
    throw const InitializationException('Firebase has not been initialized yet.');
  }

  return FirebaseFirestore.instance;
});
