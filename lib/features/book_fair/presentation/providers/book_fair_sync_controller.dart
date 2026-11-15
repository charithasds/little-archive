import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../book/domain/entities/book_entity.dart';
import 'book_fair_sheets_service_provider.dart';

part 'book_fair_sync_controller.g.dart';

/// The possible lifecycle states of the Google Sheets sync operation.
enum BookFairSyncStatus {
  /// Nothing is happening — the default state.
  idle,

  /// Currently writing the shopping list to the Google Sheet.
  exporting,

  /// Reading checkboxes from the Google Sheet and applying updates to local DB.
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

  /// Google Sheet URL returned after a successful export.
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

/// Riverpod notifier that orchestrates the Google Sheets export and
/// pull-updates lifecycle, exposing loading/done/error states to the UI.
@riverpod
class BookFairSyncController extends _$BookFairSyncController {
  @override
  BookFairSyncState build() => const BookFairSyncState();

  BookFairSheetsService get _service => ref.read(bookFairSheetsServiceProvider);

  // ---------------------------------------------------------------------------
  // Export to Google Sheets
  // ---------------------------------------------------------------------------

  /// Writes [entries] to the shared Google Sheet (reusing the same spreadsheet
  /// if one already exists) and stores the sheet URL in state for the share
  /// dialog.
  Future<void> exportAndShare(List<BookFairExportEntry> entries) async {
    state = const BookFairSyncState(status: BookFairSyncStatus.exporting);

    try {
      final String? driveUrl = await _service.exportListToSheet(entries);
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
  // Pull updates from Google Sheets
  // ---------------------------------------------------------------------------

  /// Reads ticked checkboxes from the Google Sheet and marks those books as
  /// collected locally.
  Future<void> pullUpdates(List<BookEntity> books) async {
    state = state.copyWith(status: BookFairSyncStatus.pulling);

    try {
      final BookFairSyncResult? result = await _service.pullStatusUpdates(books);
      if (result == null) {
        state = state.copyWith(
          status: BookFairSyncStatus.error,
          error: 'No shared Google Sheet found. '
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
