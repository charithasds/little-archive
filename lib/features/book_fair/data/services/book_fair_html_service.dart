import 'dart:convert';

import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/sync/data/services/backup_service.dart' show GoogleAuthClient;
import '../../../book/data/repositories/book_repository_impl.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/domain/repositories/book_repository.dart';

part 'book_fair_html_service.g.dart';

// SharedPreferences key for the Drive file ID (replaces _kSheetIdKey).
const String _kHtmlFileIdKey = 'book_fair_html_file_id';
const String _kHtmlFileName = 'Little Archive Book Fair Shopping List.html';

// Only Drive scope needed — no Sheets scope.
const List<String> _kDriveScopes = <String>[
  drive.DriveApi.driveFileScope,
];

/// Data class carrying everything needed to render one row in the HTML.
class BookFairExportEntry {
  const BookFairExportEntry({
    required this.book,
    required this.creators,
    required this.publisherName,
    required this.halls,
    required this.stallNo,
    required this.stallName,
  });

  final BookEntity book;
  final String creators;
  final String publisherName;
  final List<String> halls;
  final String stallNo;
  final String stallName;
}

/// Result returned after a sync (pull) operation.
class BookFairSyncResult {
  const BookFairSyncResult({
    required this.updatedBookTitles,
    required this.conflictBookTitles,
  });

  final List<String> updatedBookTitles;
  final List<String> conflictBookTitles;
}

class BookFairHtmlService {
  BookFairHtmlService({required this.bookRepository});

  final BookRepository bookRepository;

  static String get _clientId => dotenv.env['GOOGLE_CLIENT_ID_WEB'] ?? '';

  // ---------------------------------------------------------------------------
  // Google auth (same pattern as BackupService / old SheetsService)
  // ---------------------------------------------------------------------------

  Future<GoogleAuthClient?> _buildAuthClient() async {
    try {
      await GoogleSignIn.instance.initialize(
        clientId: _clientId,
        serverClientId: _clientId,
      );
      final GoogleSignInAccount user = await GoogleSignIn.instance.authenticate();
      final GoogleSignInClientAuthorization auth =
          await user.authorizationClient.authorizeScopes(_kDriveScopes);
      return GoogleAuthClient(
        <String, String>{'Authorization': 'Bearer ${auth.accessToken}'},
      );
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Export & Upload to Drive (Issues #4 + #7)
  // ---------------------------------------------------------------------------

  /// Generates the HTML shopping list from [entries] and uploads it to Google
  /// Drive, reusing the same file if one was created previously.
  ///
  /// Returns the public Google Drive view URL on success, null on failure.
  /// The Drive file ID is persisted to SharedPreferences for later sync.
  Future<String?> exportAndUpload(List<BookFairExportEntry> entries) async {
    final GoogleAuthClient? client = await _buildAuthClient();
    if (client == null) {
      return null;
    }

    final drive.DriveApi driveApi = drive.DriveApi(client);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fileId = prefs.getString(_kHtmlFileIdKey);

    final String htmlContent = await _buildHtml(entries);
    final List<int> htmlBytes = utf8.encode(htmlContent);

    // Try to reuse and overwrite the existing Drive file.
    if (fileId != null) {
      try {
        await driveApi.files.update(
          drive.File(),
          fileId,
          uploadMedia: drive.Media(
            Stream<List<int>>.fromIterable(<List<int>>[htmlBytes]),
            htmlBytes.length,
            contentType: 'text/html',
          ),
        );
      } catch (_) {
        // File may have been deleted from Drive — fall through to re-create.
        fileId = null;
      }
    }

    // Look for an existing file by name on Drive to avoid duplicates.
    if (fileId == null) {
      try {
        final drive.FileList found = await driveApi.files.list(
          q: "name = '$_kHtmlFileName' and mimeType = 'text/html' and trashed = false",
          spaces: 'drive',
        );
        if (found.files != null && found.files!.isNotEmpty) {
          fileId = found.files!.first.id;
          // Overwrite the found file.
          await driveApi.files.update(
            drive.File(),
            fileId!,
            uploadMedia: drive.Media(
              Stream<List<int>>.fromIterable(<List<int>>[htmlBytes]),
              htmlBytes.length,
              contentType: 'text/html',
            ),
          );
        }
      } catch (_) {
        // Fall through to create a new file.
      }
    }

    if (fileId == null) {
      final drive.File created = await driveApi.files.create(
        drive.File()
          ..name = _kHtmlFileName
          ..mimeType = 'text/html',
        uploadMedia: drive.Media(
          Stream<List<int>>.fromIterable(<List<int>>[htmlBytes]),
          htmlBytes.length,
          contentType: 'text/html',
        ),
      );
      fileId = created.id;
    }

    if (fileId == null) {
      return null;
    }
    final String resolvedFileId = fileId;

    // Make the file publicly viewable (anyone with link can view).
    try {
      await driveApi.permissions.create(
        drive.Permission()
          ..role = 'writer'
          ..type = 'anyone',
        resolvedFileId,
      );
    } catch (_) {
      // Ignore if permission already exists.
    }

    await prefs.setString(_kHtmlFileIdKey, resolvedFileId);

    return 'https://drive.google.com/file/d/$resolvedFileId/view';
  }

  // ---------------------------------------------------------------------------
  // Sync / Pull from Drive (Issue #7)
  // ---------------------------------------------------------------------------

  /// Downloads the HTML from Drive, parses checked book IDs, marks those books
  /// as collected in the local repository, then writes the updated HTML back to
  /// Drive with the synced rows removed.
  Future<BookFairSyncResult?> pullStatusUpdates(
      List<BookEntity> currentBooks) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? fileId = prefs.getString(_kHtmlFileIdKey);
    if (fileId == null) {
      return null;
    }

    final GoogleAuthClient? client = await _buildAuthClient();
    if (client == null) {
      return null;
    }

    final drive.DriveApi driveApi = drive.DriveApi(client);

    // Download the HTML content from Drive.
    String html;
    try {
      final drive.Media media = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;
      final List<int> bytes = await media.stream.expand((List<int> b) => b).toList();
      html = utf8.decode(bytes);
    } catch (e) {
      if (e.toString().contains('404')) {
        throw Exception(
          'Could not find the HTML file in Google Drive. It may have been deleted. '
          'Please share the list again to create a new file.',
        );
      }
      rethrow;
    }

    // Parse checked book IDs.
    final Set<String> checkedIds = _parseCheckedBookIds(html);

    final List<String> updatedBookTitles = <String>[];
    final List<String> conflictBookTitles = <String>[];
    final List<String> syncedIds = <String>[];

    for (final String bookId in checkedIds) {
      final BookEntity? book = currentBooks
          .where((BookEntity b) => b.id == bookId)
          .cast<BookEntity?>()
          .firstOrNull;

      if (book == null) {
        continue;
      }

      if (book.collectionStatus == CollectionStatus.collected) {
        conflictBookTitles.add(book.title);
        syncedIds.add(bookId);
        continue;
      }

      final BookEntity updated = book.copyWith(
        collectionStatus: CollectionStatus.collected,
        collectedDate: Nullable<DateTime?>(book.collectedDate ?? DateTime.now()),
        lastUpdated: DateTime.now(),
      );

      await bookRepository.editBook(updated);
      updatedBookTitles.add(book.title);
      syncedIds.add(bookId);
    }

    // Issue #7: Write the updated HTML back to Drive with synced rows removed.
    if (syncedIds.isNotEmpty) {
      final String updatedHtml = _removeCheckedRows(html, syncedIds.toSet());
      final List<int> updatedBytes = utf8.encode(updatedHtml);
      try {
        await driveApi.files.update(
          drive.File(),
          fileId,
          uploadMedia: drive.Media(
            Stream<List<int>>.fromIterable(<List<int>>[updatedBytes]),
            updatedBytes.length,
            contentType: 'text/html',
          ),
        );
      } catch (_) {
        // Non-fatal — local DB updates already succeeded.
      }
    }

    return BookFairSyncResult(
      updatedBookTitles: updatedBookTitles,
      conflictBookTitles: conflictBookTitles,
    );
  }

  // ---------------------------------------------------------------------------
  // HTML generation helpers
  // ---------------------------------------------------------------------------

  Future<String> _buildHtml(List<BookFairExportEntry> entries) async {
    String logoBase64 = '';
    try {
      final ByteData logoData = await rootBundle.load('assets/icon/app_icon.png');
      logoBase64 = base64Encode(
        logoData.buffer.asUint8List(
          logoData.offsetInBytes,
          logoData.lengthInBytes,
        ),
      );
    } catch (_) {
      // Fallback if asset cannot be loaded.
    }

    final String logoTag = logoBase64.isNotEmpty
        ? '<img class="header-logo" src="data:image/png;base64,$logoBase64" alt="Little Archive">'
        : '';

    final StringBuffer sb = StringBuffer();
    sb.writeln('<!DOCTYPE html>');
    sb.writeln('<html lang="en">');
    sb.writeln('<head>');
    sb.writeln('  <meta charset="utf-8">');
    sb.writeln('  <meta name="viewport" content="width=device-width, initial-scale=1">');
    sb.writeln('  <title>Little Archive — Book Fair Shopping List</title>');
    sb.writeln('  <link rel="preconnect" href="https://fonts.googleapis.com">');
    sb.writeln('  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>');
    sb.writeln('  <link href="https://fonts.googleapis.com/css2?family=Merriweather:ital,wght@0,300;0,400;0,700;1,300;1,400&display=swap" rel="stylesheet">');
    sb.writeln('  <style>');
    sb.writeln("    body { font-family: 'Merriweather', Georgia, serif; line-height: 1.5; max-width: 860px; margin: 0 auto; padding: 16px; background-color: #FFFFFF; color: #1C1B1F; }");
    sb.writeln('    .header { display: flex; align-items: center; gap: 16px; margin: 12px 0 20px 0; }');
    sb.writeln('    .header-logo { width: 56px; height: 56px; object-fit: contain; flex-shrink: 0; border-radius: 12px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15); }');
    sb.writeln('    h1 { color: #7B1FA2; white-space: nowrap; margin: 0; font-size: 1.45rem; font-weight: 700; }');
    sb.writeln('    table { border-collapse: collapse; width: 100%; border: 1px solid #E0E0E0; }');
    sb.writeln('    th { background: #7B1FA2; color: #FFFFFF; text-align: left; padding: 10px 12px; font-size: 0.95rem; }');
    sb.writeln('    tr { background: #FFFFFF; border-bottom: 1px solid #E0E0E0; }');
    sb.writeln('    tr:nth-child(even) { background: #F3E5F5; }');
    sb.writeln('    td { padding: 8px 12px; vertical-align: middle; border-bottom: 1px solid #E0E0E0; color: #1C1B1F; }');
    sb.writeln('    input[type=checkbox] { width: 20px; height: 20px; cursor: pointer; accent-color: #7B1FA2; }');
    sb.writeln('    .title-cell { display: flex; align-items: center; gap: 10px; }');
    sb.writeln('    .book-cover { width: 44px; height: 60px; object-fit: cover; border-radius: 4px; flex-shrink: 0; box-shadow: 0 1px 4px rgba(0, 0, 0, 0.2); }');
    sb.writeln('  </style>');
    sb.writeln('</head>');
    sb.writeln('<body>');
    sb.writeln('  <div class="header">');
    if (logoTag.isNotEmpty) {
      sb.writeln('    $logoTag');
    }
    sb.writeln('    <h1>Book Fair Shopping List</h1>');
    sb.writeln('  </div>');
    sb.writeln('  <table>');
    sb.writeln('    <thead>');
    sb.writeln('      <tr>');
    sb.writeln('        <th>Collected?</th>');
    sb.writeln('        <th>Title</th>');
    sb.writeln('        <th>Creators</th>');
    sb.writeln('        <th>Hall</th>');
    sb.writeln('        <th>Stall</th>');
    sb.writeln('        <th>Publisher</th>');
    sb.writeln('      </tr>');
    sb.writeln('    </thead>');
    sb.writeln('    <tbody>');

    for (final BookFairExportEntry e in entries) {
      final String escapedTitle = _escape(e.book.title);
      final String escapedCreators = _escape(e.creators);
      final String escapedPublisher = _escape(e.publisherName);
      final String escapedHall = _escape(e.halls.join(', '));
      final String escapedStall = _escape('${e.stallNo}  ${e.stallName}'.trim());
      final String? coverSrc = _formatCoverSrc(e.book.cover);
      final String coverHtml = (coverSrc != null && coverSrc.isNotEmpty)
          ? '<a href="$coverSrc" target="_blank" rel="noopener noreferrer"><img class="book-cover" src="$coverSrc" alt="Cover"></a>'
          : '';

      sb.writeln('      <tr>');
      // data-book-id is the Firestore book ID used by the sync parser.
      sb.writeln('        <td><input type="checkbox" data-book-id="${e.book.id}"></td>');
      sb.writeln('        <td><div class="title-cell">$coverHtml<span>$escapedTitle</span></div></td>');
      sb.writeln('        <td>$escapedCreators</td>');
      sb.writeln('        <td>$escapedHall</td>');
      sb.writeln('        <td>$escapedStall</td>');
      sb.writeln('        <td>$escapedPublisher</td>');
      sb.writeln('      </tr>');
    }

    sb.writeln('    </tbody>');
    sb.writeln('  </table>');
    sb.writeln('</body>');
    sb.writeln('</html>');
    return sb.toString();
  }

  /// Minimal HTML escaping for text content.
  String _escape(String text) => text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  /// Formats a book cover string into a valid img src (URL or data URI).
  String? _formatCoverSrc(String? cover) {
    if (cover == null || cover.isEmpty) {
      return null;
    }
    if (cover.startsWith('http://') ||
        cover.startsWith('https://') ||
        cover.startsWith('data:image/')) {
      return cover;
    }
    if (cover.startsWith('iVBORw0KGgo')) {
      return 'data:image/png;base64,$cover';
    }
    return 'data:image/jpeg;base64,$cover';
  }

  // ---------------------------------------------------------------------------
  // Sync parsing helpers
  // ---------------------------------------------------------------------------

  /// Parses the raw HTML and returns the set of book IDs whose checkboxes are
  /// marked as checked (i.e. contain the `checked` attribute).
  Set<String> _parseCheckedBookIds(String html) {
    final Set<String> ids = <String>{};
    final RegExp inputTag = RegExp(r'<input\b[^>]*>', caseSensitive: false);
    for (final RegExpMatch match in inputTag.allMatches(html)) {
      final String tag = match.group(0)!;
      final bool isChecked =
          RegExp(r'\bchecked\b', caseSensitive: false).hasMatch(tag);
      if (!isChecked) {
        continue;
      }
      final RegExpMatch? idMatch =
          RegExp(r'data-book-id="([^"]+)"', caseSensitive: false).firstMatch(tag);
      if (idMatch != null) {
        ids.add(idMatch.group(1)!);
      }
    }
    return ids;
  }

  /// Removes table rows whose checkbox `data-book-id` is in [syncedIds].
  String _removeCheckedRows(String html, Set<String> syncedIds) {
    if (syncedIds.isEmpty) {
      return html;
    }
    String result = html;
    for (final String id in syncedIds) {
      final RegExp rowPattern = RegExp(
        r'<tr>[\s\S]*?data-book-id="' + RegExp.escape(id) + r'"[\s\S]*?</tr>',
        caseSensitive: false,
      );
      result = result.replaceAll(rowPattern, '');
    }
    return result;
  }
}

@riverpod
BookFairHtmlService bookFairHtmlService(Ref ref) {
  final BookRepository bookRepository = ref.watch(bookRepositoryProvider);
  return BookFairHtmlService(bookRepository: bookRepository);
}
