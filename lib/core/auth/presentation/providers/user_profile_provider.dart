import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_provider.dart';

part 'user_profile_provider.g.dart';

@riverpod
Stream<Map<String, dynamic>?> userProfile(Ref ref) {
  final String? uid = ref.watch(currentUidProvider);
  
  if (uid == null) {
    return Stream<Map<String, dynamic>?>.value(null);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((DocumentSnapshot<Map<String, dynamic>> snapshot) => snapshot.data());
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
