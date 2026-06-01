import 'package:firebase_auth/firebase_auth.dart' as firebase;

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.email,
    super.displayName,
    super.photoUrl,
    super.lastConfiguredFairId,
  });

  factory UserModel.fromFirebase(firebase.User user) => UserModel(
    uid: user.uid,
    email: user.email,
    displayName: user.displayName,
    photoUrl: user.photoURL,
  );
}
