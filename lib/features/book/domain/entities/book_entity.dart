import 'package:equatable/equatable.dart';
import '../../../../core/enums/compilation_type.dart';
import '../../../../core/enums/language.dart';
import '../../../../core/enums/genre.dart';
import '../../../../core/enums/original_language.dart';
import '../../../../core/enums/collection_status.dart';
import '../../../../core/enums/reading_status.dart';

class BookEntity extends Equatable {
  final String id;
  final String title;
  final String? cover;
  final CompilationType compilationType;
  final Language language;
  final Genre genre;
  final String? isbn;
  final DateTime? publishedDate;
  final int? noOfPages;
  final bool isTranslation;
  final String? originalTitle;
  final OriginalLanguage? originalLanguage;
  final CollectionStatus collectionStatus;
  final DateTime? collectedDate;
  final DateTime? lendedDate;
  final DateTime? dueDate;
  final ReadingStatus readingStatus;
  final int? pausedPage;
  final DateTime? completedDate;
  final String? notes;
  final DateTime createdDate;
  final DateTime lastUpdated;
  final List<String> authorIds;
  final List<String> translatorIds;
  final List<String> shortIds;
  final String? sequenceVolumeId;
  final String? publisherId;
  final String? readerId;

  const BookEntity({
    required this.id,
    required this.title,
    this.cover,
    required this.compilationType,
    required this.language,
    required this.genre,
    this.isbn,
    this.publishedDate,
    this.noOfPages,
    required this.isTranslation,
    this.originalTitle,
    this.originalLanguage,
    required this.collectionStatus,
    this.collectedDate,
    this.lendedDate,
    this.dueDate,
    required this.readingStatus,
    this.pausedPage,
    this.completedDate,
    this.notes,
    required this.createdDate,
    required this.lastUpdated,
    required this.authorIds,
    required this.translatorIds,
    required this.shortIds,
    this.sequenceVolumeId,
    this.publisherId,
    this.readerId,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    cover,
    compilationType,
    language,
    genre,
    isbn,
    publishedDate,
    noOfPages,
    isTranslation,
    originalTitle,
    originalLanguage,
    collectionStatus,
    collectedDate,
    lendedDate,
    dueDate,
    readingStatus,
    pausedPage,
    completedDate,
    notes,
    createdDate,
    lastUpdated,
    authorIds,
    translatorIds,
    shortIds,
    sequenceVolumeId,
    publisherId,
    readerId,
  ];
}
