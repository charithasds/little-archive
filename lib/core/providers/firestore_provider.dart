import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/relationship_sync_service.dart';

final Provider<FirebaseFirestore> firestoreProvider = Provider<FirebaseFirestore>((Ref ref) {
  return FirebaseFirestore.instance;
});

final Provider<RelationshipSyncService> relationshipSyncServiceProvider = Provider<RelationshipSyncService>((
  Ref ref,
) {
  final FirebaseFirestore firestore = ref.watch(firestoreProvider);
  return RelationshipSyncService(firestore: firestore);
});
