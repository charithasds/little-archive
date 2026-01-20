import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/compilation_type.dart';
import '../../../../core/enums/language.dart';
import '../../../../core/enums/genre.dart';
import '../../../../core/enums/original_language.dart';
import '../../../../core/enums/collection_status.dart';
import '../../../../core/enums/reading_status.dart';
import '../../domain/entities/book_entity.dart';

class BookModel extends BookEntity {
  const BookModel({
    required super.id,
    required super.title,
    super.cover,
    required super.compilationType,
    required super.language,
    required super.genre,
    super.isbn,
    super.publishedDate,
    super.noOfPages,
    required super.isTranslation,
    super.originalTitle,
    super.originalLanguage,
    required super.collectionStatus,
    super.collectedDate,
    super.lendedDate,
    super.dueDate,
    required super.readingStatus,
    super.pausedPage,
    super.completedDate,
    super.notes,
    required super.createdDate,
    required super.lastUpdated,
    required super.authorIds,
    required super.translatorIds,
    required super.shortIds,
    super.sequenceVolumeId,
    super.publisherId,
    super.readerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'cover': cover,
      'compilationType': compilationType.name,
      'language': language.name,
      'genre': genre.name,
      'isbn': isbn,
      'publishedDate': publishedDate != null
          ? Timestamp.fromDate(publishedDate!)
          : null,
      'noOfPages': noOfPages,
      'isTranslation': isTranslation,
      'originalTitle': originalTitle,
      'originalLanguage': originalLanguage?.name,
      'collectionStatus': collectionStatus.name,
      'collectedDate': collectedDate != null
          ? Timestamp.fromDate(collectedDate!)
          : null,
      'lendedDate': lendedDate != null ? Timestamp.fromDate(lendedDate!) : null,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'readingStatus': readingStatus.name,
      'pausedPage': pausedPage,
      'completedDate': completedDate != null
          ? Timestamp.fromDate(completedDate!)
          : null,
      'notes': notes,
      'createdDate': Timestamp.fromDate(createdDate),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'authorIds': authorIds,
      'translatorIds': translatorIds,
      'shortIds': shortIds,
      'sequenceVolumeId': sequenceVolumeId,
      'publisherId': publisherId,
      'readerId': readerId,
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BookModel(
      id: documentId,
      title: map['title'] ?? '',
      cover: map['cover'],
      compilationType: CompilationType.values.byName(
        map['compilationType'] ?? 'single',
      ),
      language: Language.values.byName(map['language'] ?? 'english'),
      genre: Genre.values.byName(map['genre'] ?? 'other'),
      isbn: map['isbn'],
      publishedDate: (map['publishedDate'] as Timestamp?)?.toDate(),
      noOfPages: map['noOfPages'],
      isTranslation: map['isTranslation'] ?? false,
      originalTitle: map['originalTitle'],
      originalLanguage: map['originalLanguage'] != null
          ? OriginalLanguage.values.byName(map['originalLanguage'])
          : null,
      collectionStatus: CollectionStatus.values.byName(
        map['collectionStatus'] ?? 'owned',
      ),
      collectedDate: (map['collectedDate'] as Timestamp?)?.toDate(),
      lendedDate: (map['lendedDate'] as Timestamp?)?.toDate(),
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      readingStatus: ReadingStatus.values.byName(
        map['readingStatus'] ?? 'notStarted',
      ),
      pausedPage: map['pausedPage'],
      completedDate: (map['completedDate'] as Timestamp?)?.toDate(),
      notes: map['notes'],
      createdDate:
          (map['createdDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated:
          (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      authorIds: List<String>.from(map['authorIds'] ?? []),
      translatorIds: List<String>.from(map['translatorIds'] ?? []),
      shortIds: List<String>.from(map['shortIds'] ?? []),
      sequenceVolumeId: map['sequenceVolumeId'],
      publisherId: map['publisherId'],
      readerId: map['readerId'],
    );
  }
}
