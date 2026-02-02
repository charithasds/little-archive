import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {

  const UserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  @override
  List<Object?> get props => <Object?>[uid];
}
