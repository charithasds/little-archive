import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_provider.dart';

part 'user_profile_provider.g.dart';

@riverpod
Stream<UserEntity?> userProfile(Ref ref) {
  final String? uid = ref.watch(currentUidProvider);
  
  if (uid == null) {
    return Stream<UserEntity?>.value(null);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
        final Map<String, dynamic>? data = snapshot.data();
        if (data == null) {
          return null;
        }
        return UserEntity(
          uid: uid,
          email: data['email'] as String?,
          displayName: data['displayName'] as String?,
          photoUrl: data['photoUrl'] as String?,
          lastConfiguredFairId: data['lastConfiguredFairId'] as String?,
        );
      });
}

@Riverpod(keepAlive: true)
class UserProfileController extends _$UserProfileController {
  @override
  AsyncValue<void> build() => const AsyncValue<void>.data(null);

  Future<void> updateLastConfiguredFairId(String? fairId) async {
    final String? uid = ref.read(currentUidProvider);

    if (uid == null) {
      return;
    }

    state = const AsyncValue<void>.loading();
    state = await AsyncValue.guard(() async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(<String, dynamic>{
            'lastConfiguredFairId': fairId,
          }, SetOptions(merge: true));
    });
  }
}
