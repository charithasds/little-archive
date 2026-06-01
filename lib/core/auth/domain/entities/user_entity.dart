import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.lastConfiguredFairId,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? lastConfiguredFairId;

  @override
  List<Object?> get props => <Object?>[uid];
}
