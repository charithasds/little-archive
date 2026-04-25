import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/shared/domain/enums/genre.dart';
import '../../../../core/shared/domain/enums/language.dart' as local_lang;
import '../../../../core/shared/domain/enums/original_language.dart';

part 'book_scanner_remote_data_source.g.dart';

abstract class BookScannerRemoteDataSource {
  Future<Map<String, dynamic>> scanBookCover(Uint8List imageBytes);
}

class BookScannerRemoteDataSourceImpl implements BookScannerRemoteDataSource {
  BookScannerRemoteDataSourceImpl();

  @override
  Future<Map<String, dynamic>> scanBookCover(Uint8List imageBytes) async {
    const TextPart prompt = TextPart(
      'Return ONLY JSON. If the book is not recognized with high certainty (>99%), provide OCR text in the corresponding fields instead of metadata.',
    );
    final GenerativeModel model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: <String, Schema>{
            'title': Schema.string(),
            'isTranslation': Schema.boolean(),
            'language': Schema.enumString(
              enumValues: local_lang.Language.values
                  .map((local_lang.Language e) => e.name)
                  .toList(),
            ),
            'originalTitle': Schema.string(nullable: true),
            'originalLanguage': Schema.enumString(
              enumValues: OriginalLanguage.values.map((OriginalLanguage e) => e.name).toList(),
              nullable: true,
            ),
            'authorNames': Schema.array(items: Schema.string()),
            'translatorNames': Schema.array(items: Schema.string()),
            'publisher': Schema.string(),
            'publishedDate': Schema.string(),
            'noOfPages': Schema.integer(),
            'isbn': Schema.string(),
            'genre': Schema.enumString(enumValues: Genre.values.map((Genre e) => e.name).toList()),
          },
        ),
      ),
    );
    final InlineDataPart imagePart = InlineDataPart('image/jpeg', imageBytes);
    final GenerateContentResponse response = await model.generateContent(<Content>[
      Content.multi(<Part>[prompt, imagePart]),
    ]);

    if (response.text == null) {
      throw Exception('Gemini returned an empty response.');
    }

    return jsonDecode(response.text!) as Map<String, dynamic>;
  }
}

@riverpod
BookScannerRemoteDataSource bookScannerRemoteDataSource(Ref ref) =>
    BookScannerRemoteDataSourceImpl();
