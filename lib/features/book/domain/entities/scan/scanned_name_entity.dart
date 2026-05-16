import 'package:equatable/equatable.dart';

class ScannedNameEntity extends Equatable {
  const ScannedNameEntity({required this.name, this.otherName});

  final String name;
  final String? otherName;

  @override
  List<Object?> get props => <Object?>[name, otherName];
}
