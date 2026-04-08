import 'package:equatable/equatable.dart';

import '../../../../core/shared/domain/enums/content_category.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../../../core/shared/domain/enums/reading_status.dart';

class WorkEntity extends Equatable {
  const WorkEntity({
    required this.id,

    required this.title,
    required this.language,
    required this.genre,
    required this.contentCategory,
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
    required this.sequenceVolumeIds,
    this.bookId,
  });
  final String id;

  final String title;
  final Language language;
  final Genre genre;
  final ContentCategory contentCategory;
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
  final List<String> sequenceVolumeIds;
  final String? bookId;

  @override
  List<Object?> get props => <Object?>[id];

  WorkEntity copyWith({
    String? id,

    String? title,
    Language? language,
    Genre? genre,
    ContentCategory? contentCategory,
    int? noOfPages,
    bool? isTranslation,
    String? originalTitle,
    OriginalLanguage? originalLanguage,
    ReadingStatus? readingStatus,
    int? pausedPage,
    DateTime? completedDate,
    String? notes,
    DateTime? createdDate,
    DateTime? lastUpdated,
    List<String>? authorIds,
    List<String>? translatorIds,
    List<String>? sequenceVolumeIds,
    String? bookId,
  }) => WorkEntity(
    id: id ?? this.id,

    title: title ?? this.title,
    language: language ?? this.language,
    genre: genre ?? this.genre,
    contentCategory: contentCategory ?? this.contentCategory,
    noOfPages: noOfPages ?? this.noOfPages,
    isTranslation: isTranslation ?? this.isTranslation,
    originalTitle: originalTitle ?? this.originalTitle,
    originalLanguage: originalLanguage ?? this.originalLanguage,
    readingStatus: readingStatus ?? this.readingStatus,
    pausedPage: pausedPage ?? this.pausedPage,
    completedDate: completedDate ?? this.completedDate,
    notes: notes ?? this.notes,
    createdDate: createdDate ?? this.createdDate,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    authorIds: authorIds ?? this.authorIds,
    translatorIds: translatorIds ?? this.translatorIds,
    sequenceVolumeIds: sequenceVolumeIds ?? this.sequenceVolumeIds,
    bookId: bookId ?? this.bookId,
  );
}
