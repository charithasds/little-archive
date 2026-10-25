import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../book/domain/entities/book_entity.dart';
import '../../data/services/book_fair_html_service.dart';

part 'book_fair_sync_controller.g.dart';

/// The possible lifecycle states of the Drive HTML sync operation.
enum BookFairSyncStatus {
  /// Nothing is happening — the default state.
  idle,

  /// Currently generating the HTML and uploading it to Drive.
  exporting,

  /// Downloading the HTML from Drive and applying updates to local DB.
  pulling,

  /// Last operation completed successfully.
  done,

  /// Last operation ended with an error.
  error,
}

/// Immutable state snapshot for [BookFairSyncController].
class BookFairSyncState {
  const BookFairSyncState({
    this.status = BookFairSyncStatus.idle,
    this.sheetUrl,
    this.error,
    this.updatedBookTitles,
    this.conflictBookTitles,
  });

  final BookFairSyncStatus status;

  /// Google Drive view URL returned after a successful upload.
  /// Used by the share dialog to display a QR code or copy link.
  final String? sheetUrl;

  /// Error message; populated when [status] is [BookFairSyncStatus.error].
  final String? error;

  /// Titles of books whose status was updated during a pull.
  final List<String>? updatedBookTitles;

  /// Titles of books that were already Collected both locally and remotely.
  final List<String>? conflictBookTitles;

  BookFairSyncState copyWith({
    BookFairSyncStatus? status,
    String? sheetUrl,
    String? error,
    List<String>? updatedBookTitles,
    List<String>? conflictBookTitles,
  }) =>
      BookFairSyncState(
        status: status ?? this.status,
        sheetUrl: sheetUrl ?? this.sheetUrl,
        error: error ?? this.error,
        updatedBookTitles: updatedBookTitles ?? this.updatedBookTitles,
        conflictBookTitles: conflictBookTitles ?? this.conflictBookTitles,
      );
}

/// Riverpod notifier that orchestrates the Drive HTML export/upload and
/// pull-updates lifecycle, exposing loading/done/error states to the UI.
@riverpod
class BookFairSyncController extends _$BookFairSyncController {
  @override
  BookFairSyncState build() => const BookFairSyncState();

  BookFairHtmlService get _service => ref.read(bookFairHtmlServiceProvider);

  // ---------------------------------------------------------------------------
  // Export & Upload to Drive
  // ---------------------------------------------------------------------------

  /// Generates an HTML shopping list from [entries], uploads it to Google Drive
  /// (reusing the same file if one already exists), and stores the Drive view
  /// URL in state for the share dialog.
  Future<void> exportAndShare(List<BookFairExportEntry> entries) async {
    state = const BookFairSyncState(status: BookFairSyncStatus.exporting);

    try {
      final String? driveUrl = await _service.exportAndUpload(entries);
      if (driveUrl == null) {
        state = const BookFairSyncState(
          status: BookFairSyncStatus.error,
          error: 'Upload failed. Please sign in and try again.',
        );
        return;
      }
      state = BookFairSyncState(
        status: BookFairSyncStatus.done,
        sheetUrl: driveUrl,
      );
    } catch (e) {
      state = BookFairSyncState(
        status: BookFairSyncStatus.error,
        error: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Pull updates from Drive
  // ---------------------------------------------------------------------------

  /// Downloads the HTML from Drive, parses checked boxes, marks books collected
  /// locally, and writes the pruned HTML back to Drive.
  Future<void> pullUpdates(List<BookEntity> books) async {
    state = state.copyWith(status: BookFairSyncStatus.pulling);

    try {
      final BookFairSyncResult? result = await _service.pullStatusUpdates(books);
      if (result == null) {
        state = state.copyWith(
          status: BookFairSyncStatus.error,
          error: 'No HTML file found in Google Drive. '
              'Please share the list first.',
        );
        return;
      }
      state = state.copyWith(
        status: BookFairSyncStatus.done,
        updatedBookTitles: result.updatedBookTitles,
        conflictBookTitles: result.conflictBookTitles,
      );
    } catch (e) {
      state = state.copyWith(
        status: BookFairSyncStatus.error,
        error: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Reset
  // ---------------------------------------------------------------------------

  void reset() => state = const BookFairSyncState();
}
