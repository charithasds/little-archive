import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/scanned_book_entity.dart';
import '../../domain/usecases/scan_book_use_case.dart';

part 'book_scanner_controller.g.dart';

@riverpod
class BookScannerController extends _$BookScannerController {
  @override
  AsyncValue<ScannedBookEntity?> build() => const AsyncData<ScannedBookEntity?>(null);

  Future<void> scanBook(Uint8List imageBytes) async {
    state = const AsyncLoading<ScannedBookEntity?>();

    try {
      final ScanBookUseCase useCase = ref.read(scanBookUseCaseProvider);
      final ScannedBookEntity result = await useCase.call(imageBytes);

      state = AsyncData<ScannedBookEntity?>(result);
    } catch (e, st) {
      state = AsyncError<ScannedBookEntity?>(e, st);
    }
  }

  void reset() {
    state = const AsyncData<ScannedBookEntity?>(null);
  }
}
