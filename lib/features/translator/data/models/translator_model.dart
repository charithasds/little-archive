import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/translator_entity.dart';

class TranslatorModel extends TranslatorEntity {
  const TranslatorModel({
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

  factory TranslatorModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TranslatorModel(
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
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
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
}
