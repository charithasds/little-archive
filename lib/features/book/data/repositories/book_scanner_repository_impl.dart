import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/shared/domain/enums/compilation_type.dart';
import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart';
import '../../../../core/shared/domain/enums/original_language.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/scanned_book_entity.dart';
import '../../domain/repositories/book_scanner_repository.dart';
import '../datasources/book_scanner_remote_data_source.dart';

part 'book_scanner_repository_impl.g.dart';

class BookScannerRepositoryImpl implements BookScannerRepository {
  BookScannerRepositoryImpl(this.remoteDataSource);

  final BookScannerRemoteDataSource remoteDataSource;

  @override
  Future<ScannedBookEntity> scanBookCover(Uint8List imageBytes) async {
    final Map<String, dynamic> data = await remoteDataSource.scanBookCover(imageBytes);

    final String title = data['title'] as String? ?? '';
    final bool isTranslation = data['isTranslation'] as bool? ?? false;
    final String? languageStr = data['language'] as String?;
    final String? originalTitle = data['originalTitle'] as String?;
    final String? originalLanguageStr = data['originalLanguage'] as String?;

    final List<dynamic> authorNamesRaw = data['authorNames'] as List<dynamic>? ?? <dynamic>[];
    final List<String> authorNames = authorNamesRaw.map((dynamic e) => e.toString()).toList();

    final List<dynamic> translatorNamesRaw =
        data['translatorNames'] as List<dynamic>? ?? <dynamic>[];
    final List<String> translatorNames = translatorNamesRaw
        .map((dynamic e) => e.toString())
        .toList();

    final String? publisher = data['publisher'] as String?;
    final String? publishedDateStr = data['publishedDate'] as String?;
    final int? noOfPages = data['noOfPages'] as int?;
    final String? isbn = data['isbn'] as String?;
    final String? genreStr = data['genre'] as String?;

    Language? language;

    if (languageStr != null) {
      language = Language.values.where((Language e) => e.name == languageStr).firstOrNull;
    }

    OriginalLanguage? originalLanguage;

    if (originalLanguageStr != null) {
      originalLanguage = OriginalLanguage.values
          .where((OriginalLanguage e) => e.name == originalLanguageStr)
          .firstOrNull;
    }

    Genre? genre;

    if (genreStr != null) {
      genre = Genre.values.where((Genre e) => e.name == genreStr).firstOrNull;
    }

    DateTime? publishedDate;

    if (publishedDateStr != null && publishedDateStr.isNotEmpty) {
      try {
        publishedDate = DateTime.parse(publishedDateStr);
      } catch (_) {}
    }

    final BookEntity bookEntity = BookEntity(
      id: '',
      title: title,
      compilationType: CompilationType.standalone,
      isTranslation: isTranslation,
      language: language,
      originalTitle: originalTitle,
      originalLanguage: originalLanguage,
      publishedDate: publishedDate,
      noOfPages: noOfPages,
      isbn: isbn,
      genre: genre,
      authorIds: const <String>[],
      translatorIds: const <String>[],
      workIds: const <String>[],
      sequenceVolumeIds: const <String>[],
      createdDate: DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    return ScannedBookEntity(
      book: bookEntity,
      authorNames: authorNames,
      translatorNames: translatorNames,
      publisherName: publisher,
    );
  }
}

@riverpod
BookScannerRepository bookScannerRepository(Ref ref) {
  final BookScannerRemoteDataSource remoteDataSource = ref.watch(
    bookScannerRemoteDataSourceProvider,
  );

  return BookScannerRepositoryImpl(remoteDataSource);
}
