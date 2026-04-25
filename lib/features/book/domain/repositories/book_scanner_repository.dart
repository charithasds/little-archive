import 'dart:typed_data';

import '../entities/scanned_book_entity.dart';

abstract class BookScannerRepository {
  Future<ScannedBookEntity> scanBookCover(Uint8List imageBytes);
}
