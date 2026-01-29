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

  Map<String, dynamic> toMap() {
    return {
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

  factory AuthorModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AuthorModel(
      id: documentId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      image: map['image'],
      otherName: map['otherName'],
      website: map['website'],
      facebook: map['facebook'],
      bookIds: List<String>.from(map['bookIds'] ?? []),
      workIds: List<String>.from(map['workIds'] ?? []),
      createdDate: (map['createdDate'] as Timestamp).toDate(),
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
    );
  }
}
