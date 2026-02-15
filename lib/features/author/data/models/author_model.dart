import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/author_entity.dart';

class AuthorModel extends AuthorEntity {
  const AuthorModel({
    required super.id,
    required super.userId,
    required super.name,
    super.image,
    super.otherName,
    super.website,
    super.facebook,
    required super.bookIds,
    required super.workIds,
    required super.createdDate,
    required super.lastUpdated,
  });

  factory AuthorModel.fromMap(Map<String, dynamic> map, String documentId) => AuthorModel(
    id: documentId,
    userId: (map['userId'] as String?) ?? '',
    name: (map['name'] as String?) ?? '',
    image: map['image'] as String?,
    otherName: map['otherName'] as String?,
    website: map['website'] as String?,
    facebook: map['facebook'] as String?,
    bookIds: List<String>.from(map['bookIds'] as Iterable<dynamic>? ?? <String>[]),
    workIds: List<String>.from(map['workIds'] as Iterable<dynamic>? ?? <String>[]),
    createdDate: (map['createdDate'] as Timestamp).toDate(),
    lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'userId': userId,
    'name': name,
    'image': image,
    'otherName': otherName,
    'website': website,
    'facebook': facebook,
    'bookIds': bookIds,
    'workIds': workIds,
    'createdDate': Timestamp.fromDate(createdDate),
    'lastUpdated': Timestamp.fromDate(lastUpdated),
  };
}
