import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/book_scanner_repository_impl.dart';
import '../entities/scanned_book_entity.dart';
import '../repositories/book_scanner_repository.dart';

part 'scan_book_use_case.g.dart';

class ScanBookUseCase {
  const ScanBookUseCase(this.repository);

  final BookScannerRepository repository;

  Future<ScannedBookEntity> call(Uint8List imageBytes) => repository.scanBookCover(imageBytes);
}

@riverpod
ScanBookUseCase scanBookUseCase(Ref ref) {
  final BookScannerRepository repository = ref.watch(bookScannerRepositoryProvider);
  return ScanBookUseCase(repository);
}
