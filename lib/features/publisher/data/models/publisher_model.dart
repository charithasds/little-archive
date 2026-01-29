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

  Map<String, dynamic> toMap() {
    return {
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

  factory PublisherModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PublisherModel(
      id: documentId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      logo: map['logo'],
      otherName: map['otherName'],
      website: map['website'],
      email: map['email'],
      facebook: map['facebook'],
      phoneNumber: map['phoneNumber'],
      bookIds: List<String>.from(map['bookIds'] ?? []),
      createdDate: (map['createdDate'] as Timestamp).toDate(),
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
    );
  }
}
