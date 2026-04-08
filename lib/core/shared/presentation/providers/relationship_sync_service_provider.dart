import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/relationship_sync_service.dart';
import 'firebase_provider.dart';

/// Provides the [RelationshipSyncService] which handles synchronization between entities.
final Provider<RelationshipSyncService> relationshipSyncServiceProvider =
    Provider<RelationshipSyncService>((Ref ref) {
      final FirebaseFirestore firebaseFirestore = ref.watch(firebaseFirestoreProvider);

      return RelationshipSyncService(firestore: firebaseFirestore);
    });
