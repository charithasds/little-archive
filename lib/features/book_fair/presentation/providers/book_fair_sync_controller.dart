import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../book/domain/entities/book_entity.dart';
import '../../data/services/book_fair_sheets_service.dart';

part 'book_fair_sync_controller.g.dart';

/// The possible lifecycle states of the Sheets sync operation.
enum BookFairSyncStatus {
  /// Nothing is happening — the default state.
  idle,

  /// Currently creating the sheet and uploading data.
  exporting,

  /// Sheet created; fetching remote updates and applying to local DB.
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

  /// Current phase of the sync lifecycle.
  final BookFairSyncStatus status;

  /// The Google Sheets editing URL; populated after a successful export.
  final String? sheetUrl;

  /// Error message; populated when [status] is [BookFairSyncStatus.error].
  final String? error;

  /// Titles of books whose status was updated during a pull.
  final List<String>? updatedBookTitles;

  /// Titles of books that were marked as Collected both locally and remotely.
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

/// Riverpod notifier that orchestrates the export-to-Sheets and pull-updates
/// lifecycle, exposing loading/done/error states to the UI.
@riverpod
class BookFairSyncController extends _$BookFairSyncController {
  @override
  BookFairSyncState build() => const BookFairSyncState();

  BookFairSheetsService get _service =>
      ref.read(bookFairSheetsServiceProvider);

  // ---------------------------------------------------------------------------
  // Export
  // ---------------------------------------------------------------------------

  /// Creates a new Google Sheet from [entries] (enriched book data including
  /// authors, translators, publisher, and stall info) and transitions state to
  /// [BookFairSyncStatus.done] with the sheet URL on success, or
  /// [BookFairSyncStatus.error] on failure.
  Future<void> exportAndShare(List<BookFairExportEntry> entries) async {
    state = const BookFairSyncState(status: BookFairSyncStatus.exporting);

    try {
      final String? url = await _service.exportListToSheet(entries);
      if (url == null) {
        state = const BookFairSyncState(
          status: BookFairSyncStatus.error,
          error: 'Sign-in failed or sheet could not be created. '
              'Please check your Google account permissions and try again.',
        );
        return;
      }
      state = BookFairSyncState(
        status: BookFairSyncStatus.done,
        sheetUrl: url,
      );
    } catch (e) {
      state = BookFairSyncState(
        status: BookFairSyncStatus.error,
        error: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Pull updates
  // ---------------------------------------------------------------------------

  /// Fetches remote status changes from the active sheet and applies them to
  /// the local Drift DB.  Keeps [sheetUrl] intact so the dialog stays open.
  Future<void> pullUpdates(List<BookEntity> books) async {
    // Preserve the existing URL while pulling.
    state = state.copyWith(status: BookFairSyncStatus.pulling);

    try {
      final BookFairSyncResult? result = await _service.pullStatusUpdates(books);
      if (result == null) {
        state = state.copyWith(
          status: BookFairSyncStatus.error,
          error: 'Could not reach the sheet. '
              'Make sure you are signed in and have exported the list first.',
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

  /// Resets the controller back to [BookFairSyncStatus.idle] so the UI can
  /// start a fresh export cycle.
  void reset() => state = const BookFairSyncState();
}
