import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/services/relationship_sync_service.dart';
import '../../domain/error/exceptions.dart';
import 'firebase_provider.dart';

part 'relationship_sync_service_provider.g.dart';

@riverpod
RelationshipSyncService relationshipSyncService(Ref ref) {
  final FirebaseFirestore firebaseFirestore = ref.watch(firebaseFirestoreProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    throw const UnauthorizedException();
  }

  return RelationshipSyncService(
    firestore: firebaseFirestore,
    userId: userId,
  );
}
