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

  factory ReaderModel.fromMap(Map<String, dynamic> map, String documentId) => ReaderModel(
    id: documentId,
    userId: (map['userId'] as String?) ?? '',
    name: (map['name'] as String?) ?? '',
    image: map['image'] as String?,
    otherName: map['otherName'] as String?,
    email: map['email'] as String?,
    facebook: map['facebook'] as String?,
    phoneNumber: map['phoneNumber'] as String?,
    bookIds: List<String>.from(map['bookIds'] as Iterable<dynamic>? ?? <String>[]),
    createdDate: (map['createdDate'] as Timestamp).toDate(),
    lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
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
