import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/presentation/providers/auth_provider.dart';
import '../../../../core/shared/data/services/firestore_service.dart';
import '../../../../core/shared/domain/error/exceptions.dart';

part 'settings_remote_datasource.g.dart';

abstract class SettingsRemoteDataSource {
  Future<void> clearAllData();
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  SettingsRemoteDataSourceImpl({required this.firestoreService, required this.userId});

  final FirestoreService firestoreService;
  final String userId;

  FirebaseFirestore get _firestore => firestoreService.firebaseFirestore;

  @override
  Future<void> clearAllData() async {
    await firestoreService.requireConnectivity();

    final List<String> collections = <String>[
      'works',
      'translators',
      'sequences',
      'sequence_volumes',
      'readers',
      'publishers',
      'books',
      'authors',
    ];

    for (final String collection in collections) {
      final CollectionReference<Map<String, dynamic>> collectionRef = _firestore.collection(
        'users/$userId/$collection',
      );

      bool hasMore = true;
      while (hasMore) {
        final QuerySnapshot<Map<String, dynamic>> snapshot = await collectionRef.limit(500).get();
        if (snapshot.docs.isEmpty) {
          hasMore = false;
          break;
        }

        final WriteBatch batch = _firestore.batch();
        for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    }
  }
}

@riverpod
SettingsRemoteDataSource settingsRemoteDataSource(Ref ref) {
  final FirestoreService firestoreService = ref.watch(firestoreServiceProvider);
  final String? userId = ref.watch(currentUidProvider);

  if (userId == null) {
    throw const UnauthorizedException();
  }

  return SettingsRemoteDataSourceImpl(firestoreService: firestoreService, userId: userId);
}
