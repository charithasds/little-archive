import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../domain/entities/user_entity.dart';

/// Data model representing a user, extending the [UserEntity].
class UserModel extends UserEntity {
  /// Creates a [UserModel].
  const UserModel({required super.uid, super.email, super.displayName, super.photoUrl});

  /// Factory to create a [UserModel] from a Firebase [User].
  factory UserModel.fromFirebase(firebase.User user) => UserModel(
    uid: user.uid,
    email: user.email,
    displayName: user.displayName,
    photoUrl: user.photoURL,
  );
}
