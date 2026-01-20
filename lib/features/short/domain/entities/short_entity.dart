import 'package:equatable/equatable.dart';
import '../../../../core/enums/language.dart';
import '../../../../core/enums/genre.dart';
import '../../../../core/enums/original_language.dart';
import '../../../../core/enums/reading_status.dart';

class ShortEntity extends Equatable {
  final String id;
  final String title;
  final Language language;
  final Genre genre;
  final int? noOfPages;
  final bool isTranslation;
  final String? originalTitle;
  final OriginalLanguage? originalLanguage;
  final ReadingStatus readingStatus;
  final int? pausedPage;
  final DateTime? completedDate;
  final String? notes;
  final DateTime createdDate;
  final DateTime lastUpdated;
  final List<String> authorIds;
  final List<String> translatorIds;
  final String? sequenceVolumeId;
  final String? bookId;

  const ShortEntity({
    required this.id,
    required this.title,
    required this.language,
    required this.genre,
    this.noOfPages,
    required this.isTranslation,
    this.originalTitle,
    this.originalLanguage,
    required this.readingStatus,
    this.pausedPage,
    this.completedDate,
    this.notes,
    required this.createdDate,
    required this.lastUpdated,
    required this.authorIds,
    required this.translatorIds,
    this.sequenceVolumeId,
    this.bookId,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    language,
    genre,
    noOfPages,
    isTranslation,
    originalTitle,
    originalLanguage,
    readingStatus,
    pausedPage,
    completedDate,
    notes,
    createdDate,
    lastUpdated,
    authorIds,
    translatorIds,
    sequenceVolumeId,
    bookId,
  ];
}
