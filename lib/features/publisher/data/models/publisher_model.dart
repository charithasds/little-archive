import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/publisher_entity.dart';

class PublisherModel extends PublisherEntity {
  const PublisherModel({
    required super.id,
    required super.userId,
    required super.name,
    super.logo,
    super.otherName,
    super.website,
    super.email,
    super.facebook,
    super.phoneNumber,
    required super.bookIds,
    required super.createdDate,
    required super.lastUpdated,
  });

  factory PublisherModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PublisherModel(
      id: documentId,
      userId: (map['userId'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      logo: map['logo'] as String?,
      otherName: map['otherName'] as String?,
      website: map['website'] as String?,
      email: map['email'] as String?,
      facebook: map['facebook'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      bookIds: List<String>.from(map['bookIds'] as Iterable<dynamic>? ?? <String>[]),
      createdDate: (map['createdDate'] as Timestamp).toDate(),
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'name': name,
      'logo': logo,
      'otherName': otherName,
      'website': website,
      'email': email,
      'facebook': facebook,
      'phoneNumber': phoneNumber,
      'bookIds': bookIds,
      'createdDate': Timestamp.fromDate(createdDate),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
