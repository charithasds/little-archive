import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/reader_entity.dart';

class ReaderModel extends ReaderEntity {
  const ReaderModel({
    required super.id,
    required super.userId,
    required super.name,
    super.image,
    super.otherName,
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
      'image': image,
      'otherName': otherName,
      'email': email,
      'facebook': facebook,
      'phoneNumber': phoneNumber,
      'bookIds': bookIds,
      'createdDate': Timestamp.fromDate(createdDate),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  factory ReaderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ReaderModel(
      id: documentId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      image: map['image'],
      otherName: map['otherName'],
      email: map['email'],
      facebook: map['facebook'],
      phoneNumber: map['phoneNumber'],
      bookIds: List<String>.from(map['bookIds'] ?? []),
      createdDate: (map['createdDate'] as Timestamp).toDate(),
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
    );
  }
}
