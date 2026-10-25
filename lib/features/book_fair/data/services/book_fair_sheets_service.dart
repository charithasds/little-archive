import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/sync/data/services/backup_service.dart' show GoogleAuthClient;
import '../../../book/data/repositories/book_repository_impl.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/domain/repositories/book_repository.dart';

part 'book_fair_sheets_service.g.dart';

const String _kSheetIdKey = 'book_fair_sheet_id';
const String _kRootFolderIdKey = 'little_archive_root_folder_id';
const String _kCoverFolderIdKey = 'book_fair_cover_folder_id';
const String _kSheetTitle = 'Little Archive Book Fair Shopping List';
const String _kTabTitle = 'Shopping List';
const String _kRootFolderName = 'Little Archive';
const String _kCoverFolderName = 'Little Archive Book Fair Covers';
const String _kFolderMimeType = 'application/vnd.google-apps.folder';

// Drive layout:
//   Little Archive/
//   ├── Little Archive Book Fair Covers/   (anyone with link can view)
//   └── Little Archive Book Fair Shopping List   (anyone with link can edit)

/// Only the non-sensitive `drive.file` scope is requested. It grants the app
/// access (Drive + Sheets API) to files it created itself, which is all the
/// book-fair export needs, and avoids Google's sensitive-scope verification.
const List<String> _kScopes = <String>[
  drive.DriveApi.driveFileScope,
];

// -----------------------------------------------------------------------------
// Sheet layout
// -----------------------------------------------------------------------------
//   A (hidden): Book ID (used for pull-sync)
//   B: Collected? (large checkbox)
//   C: Cover (=IMAGE)
//   D: Title
//   E: Creators
//   F: Publisher
//   G: Hall
//   H: Stall
const int _kColumnCount = 8;
const int _kIdCol = 0;
const int _kCheckCol = 1;
const int _kCoverCol = 2;
const int _kTitleCol = 3;

const List<int> _kColumnWidths = <int>[
  100, // A - ID (hidden)
  90, // B - checkbox
  110, // C - cover
  260, // D - title
  190, // E - creators
  160, // F - publisher
  90, // G - hall
  170, // H - stall
];

const int _kHeaderRowHeight = 52;
const int _kDataRowHeight = 150;
const int _kCheckboxFontSize = 30; // Checkbox size scales with font size.

/// Data class carrying everything needed to render one row in the sheet.
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

/// Spreadsheet + tab identifiers resolved before writing.
class _SheetTarget {
  const _SheetTarget(this.spreadsheetId, this.sheetId);

  final String spreadsheetId;
  final int sheetId;
}

/// Existing cover file on Drive for a given book.
class _CoverFile {
  const _CoverFile(this.fileId, this.hash);

  final String fileId;
  final String? hash;
}

class BookFairSheetsService {
  BookFairSheetsService({required this.bookRepository});

  final BookRepository bookRepository;

  static String get _clientId => dotenv.env['GOOGLE_CLIENT_ID_WEB'] ?? '';

  // ---------------------------------------------------------------------------
  // Google auth (same pattern as BackupService)
  // ---------------------------------------------------------------------------

  Future<GoogleAuthClient?> _buildAuthClient() async {
    try {
      await GoogleSignIn.instance.initialize(
        clientId: _clientId,
        serverClientId: _clientId,
      );
      final GoogleSignInAccount user = await GoogleSignIn.instance.authenticate();
      final GoogleSignInClientAuthorization auth =
          await user.authorizationClient.authorizeScopes(_kScopes);
      return GoogleAuthClient(
        <String, String>{'Authorization': 'Bearer ${auth.accessToken}'},
      );
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Export
  // ---------------------------------------------------------------------------

  /// Exports the book-fair shopping list to a Google Sheet with large touch
  /// friendly checkboxes and cover thumbnails.
  ///
  /// The same spreadsheet is reused across exports so the shared link stays
  /// stable. Returns the sheet URL on success, null on auth failure.
  Future<String?> exportListToSheet(List<BookFairExportEntry> entries) async {
    final GoogleAuthClient? client = await _buildAuthClient();
    if (client == null) {
      return null;
    }

    final sheets.SheetsApi sheetsApi = sheets.SheetsApi(client);
    final drive.DriveApi driveApi = drive.DriveApi(client);
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 0. Resolve the "Little Archive" root folder.
    String? rootFolderId;
    try {
      rootFolderId = await _ensureFolder(
        driveApi,
        prefs,
        name: _kRootFolderName,
        prefsKey: _kRootFolderIdKey,
      );
    } catch (_) {
      // Fall back to My Drive root if the folder can't be created.
    }

    // 1. Resolve cover image URLs (uploads base64 covers to Drive).
    Map<String, String> coverUrls = <String, String>{};
    try {
      coverUrls = await _resolveCoverUrls(driveApi, prefs, entries, rootFolderId);
    } catch (_) {
      // Covers are nice-to-have; never block the export on them.
    }

    // 2. Find / create the spreadsheet and get a fresh, unformatted tab.
    final _SheetTarget target =
        await _prepareSpreadsheet(sheetsApi, driveApi, prefs, rootFolderId);

    // Keep the spreadsheet inside the "Little Archive" folder.
    if (rootFolderId != null) {
      await _ensureInFolder(driveApi, target.spreadsheetId, rootFolderId);
    }

    // 3. Anyone with the link can edit (needed to tick checkboxes).
    try {
      await driveApi.permissions.create(
        drive.Permission()
          ..role = 'writer'
          ..type = 'anyone',
        target.spreadsheetId,
      );
    } catch (_) {
      // Ignore if permission already exists.
    }

    await prefs.setString(_kSheetIdKey, target.spreadsheetId);

    // 4. Apply layout + formatting.
    await sheetsApi.spreadsheets.batchUpdate(
      sheets.BatchUpdateSpreadsheetRequest(
        requests: _buildFormatRequests(target.sheetId, entries.length),
      ),
      target.spreadsheetId,
    );

    // 5. Write header + rows. USER_ENTERED so =IMAGE() formulas evaluate.
    final List<List<Object>> rows = <List<Object>>[
      <Object>[
        'ID',
        'Collected?',
        'Cover',
        'Title',
        'Creators',
        'Publisher',
        'Hall',
        'Stall',
      ],
      ...entries.map((BookFairExportEntry e) {
        final String? coverUrl = coverUrls[e.book.id];
        return <Object>[
          _text(e.book.id),
          false,
          if (coverUrl != null) '=IMAGE("${coverUrl.replaceAll('"', '""')}", 1)' else '',
          _text(e.book.title),
          _text(e.creators),
          _text(e.publisherName),
          _text(e.halls.join(', ')),
          _text(
            <String>[e.stallNo, e.stallName]
                .where((String s) => s.trim().isNotEmpty)
                .join('\n'),
          ),
        ];
      }),
    ];

    await sheetsApi.spreadsheets.values.update(
      sheets.ValueRange(values: rows),
      target.spreadsheetId,
      "'$_kTabTitle'!A1",
      valueInputOption: 'USER_ENTERED',
    );

    return 'https://docs.google.com/spreadsheets/d/${target.spreadsheetId}/edit';
  }

  /// Forces a cell value to be stored as plain text (prevents values such as
  /// "=foo" or "0012" from being interpreted as formulas / numbers).
  String _text(String value) => value.isEmpty ? '' : "'$value";

  // ---------------------------------------------------------------------------
  // Spreadsheet preparation
  // ---------------------------------------------------------------------------

  Future<_SheetTarget> _prepareSpreadsheet(
    sheets.SheetsApi sheetsApi,
    drive.DriveApi driveApi,
    SharedPreferences prefs, [
    String? rootFolderId,
  ]) async {
    // 1. Reuse the stored spreadsheet.
    final String? storedId = prefs.getString(_kSheetIdKey);
    if (storedId != null) {
      final _SheetTarget? reused = await _tryReuse(sheetsApi, storedId);
      if (reused != null) {
        return reused;
      }
    }

    // 2. Look it up by name on Drive (e.g. after reinstall).
    try {
      const String nameQuery = "name = '$_kSheetTitle' and "
          "mimeType = 'application/vnd.google-apps.spreadsheet' and trashed = false";
      String? foundId;
      if (rootFolderId != null) {
        final drive.FileList inParent = await driveApi.files.list(
          q: "$nameQuery and '$rootFolderId' in parents",
          spaces: 'drive',
          $fields: 'files(id)',
        );
        foundId = inParent.files?.firstOrNull?.id;
      }
      if (foundId == null) {
        final drive.FileList found = await driveApi.files.list(
          q: nameQuery,
          spaces: 'drive',
          $fields: 'files(id)',
        );
        foundId = found.files?.firstOrNull?.id;
      }
      if (foundId != null) {
        final _SheetTarget? reused = await _tryReuse(sheetsApi, foundId);
        if (reused != null) {
          return reused;
        }
      }
    } catch (_) {
      // Fall through to create.
    }

    // 3. Create a new spreadsheet.
    final sheets.Spreadsheet created = await sheetsApi.spreadsheets.create(
      sheets.Spreadsheet(
        properties: sheets.SpreadsheetProperties(title: _kSheetTitle),
        sheets: <sheets.Sheet>[
          sheets.Sheet(properties: sheets.SheetProperties(title: _kTabTitle)),
        ],
      ),
    );
    final String? id = created.spreadsheetId;
    final int? sheetId = created.sheets?.firstOrNull?.properties?.sheetId;
    if (id == null || sheetId == null) {
      throw Exception('Failed to create the Google Sheet.');
    }
    return _SheetTarget(id, sheetId);
  }

  /// Replaces every tab in an existing spreadsheet with a brand new one.
  ///
  /// Recreating the tab wipes values, formatting, banding, validation and
  /// conditional formats in one go, so each export starts from a clean slate.
  Future<_SheetTarget?> _tryReuse(sheets.SheetsApi sheetsApi, String spreadsheetId) async {
    try {
      final sheets.Spreadsheet ss = await sheetsApi.spreadsheets.get(
        spreadsheetId,
        $fields: 'sheets.properties.sheetId',
      );
      final List<int> oldSheetIds = (ss.sheets ?? <sheets.Sheet>[])
          .map((sheets.Sheet s) => s.properties?.sheetId)
          .whereType<int>()
          .toList();

      final sheets.BatchUpdateSpreadsheetResponse res =
          await sheetsApi.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest(
          requests: <sheets.Request>[
            sheets.Request(
              addSheet: sheets.AddSheetRequest(
                properties: sheets.SheetProperties(
                  // Temporary unique title; renamed in the format batch.
                  title: 'tmp-${DateTime.now().millisecondsSinceEpoch}',
                  index: 0,
                ),
              ),
            ),
            ...oldSheetIds.map(
              (int id) => sheets.Request(
                deleteSheet: sheets.DeleteSheetRequest(sheetId: id),
              ),
            ),
          ],
        ),
        spreadsheetId,
      );

      final int? newSheetId = res.replies?.firstOrNull?.addSheet?.properties?.sheetId;
      if (newSheetId == null) {
        return null;
      }
      return _SheetTarget(spreadsheetId, newSheetId);
    } catch (_) {
      return null; // Deleted / revoked — caller will create a new one.
    }
  }

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  List<sheets.Request> _buildFormatRequests(int sheetId, int rowCount) {
    final sheets.Color purple = sheets.Color(red: 0.482, green: 0.122, blue: 0.635);
    final sheets.Color white = sheets.Color(red: 1, green: 1, blue: 1);
    final sheets.Color lightPurple = sheets.Color(red: 0.965, green: 0.937, blue: 0.976);
    final sheets.Color divider = sheets.Color(red: 0.88, green: 0.88, blue: 0.88);
    final sheets.Color doneGreen = sheets.Color(red: 0.878, green: 0.957, blue: 0.886);
    final sheets.Color doneText = sheets.Color(red: 0.46, green: 0.46, blue: 0.46);
    final sheets.Color textColor = sheets.Color(red: 0.11, green: 0.106, blue: 0.122);

    final int lastRow = rowCount + 1; // Exclusive, includes header.

    sheets.GridRange range({
      required int startRow,
      required int endRow,
      int startCol = 1,
      int endCol = _kColumnCount,
    }) =>
        sheets.GridRange(
          sheetId: sheetId,
          startRowIndex: startRow,
          endRowIndex: endRow,
          startColumnIndex: startCol,
          endColumnIndex: endCol,
        );

    final List<sheets.Request> requests = <sheets.Request>[
      // Tab title, frozen header, no gridlines, trimmed grid size.
      sheets.Request(
        updateSheetProperties: sheets.UpdateSheetPropertiesRequest(
          properties: sheets.SheetProperties(
            sheetId: sheetId,
            title: _kTabTitle,
            gridProperties: sheets.GridProperties(
              frozenRowCount: 1,
              hideGridlines: true,
              rowCount: lastRow < 2 ? 2 : lastRow,
              columnCount: _kColumnCount,
            ),
          ),
          fields: 'title,gridProperties.frozenRowCount,gridProperties.hideGridlines,'
              'gridProperties.rowCount,gridProperties.columnCount',
        ),
      ),

      // Column widths.
      for (int i = 0; i < _kColumnWidths.length; i++)
        sheets.Request(
          updateDimensionProperties: sheets.UpdateDimensionPropertiesRequest(
            range: sheets.DimensionRange(
              sheetId: sheetId,
              dimension: 'COLUMNS',
              startIndex: i,
              endIndex: i + 1,
            ),
            properties: sheets.DimensionProperties(pixelSize: _kColumnWidths[i]),
            fields: 'pixelSize',
          ),
        ),

      // Hide the ID column.
      sheets.Request(
        updateDimensionProperties: sheets.UpdateDimensionPropertiesRequest(
          range: sheets.DimensionRange(
            sheetId: sheetId,
            dimension: 'COLUMNS',
            startIndex: _kIdCol,
            endIndex: _kIdCol + 1,
          ),
          properties: sheets.DimensionProperties(hiddenByUser: true),
          fields: 'hiddenByUser',
        ),
      ),

      // Header row height.
      sheets.Request(
        updateDimensionProperties: sheets.UpdateDimensionPropertiesRequest(
          range: sheets.DimensionRange(
            sheetId: sheetId,
            dimension: 'ROWS',
            startIndex: 0,
            endIndex: 1,
          ),
          properties: sheets.DimensionProperties(pixelSize: _kHeaderRowHeight),
          fields: 'pixelSize',
        ),
      ),

      // Header style.
      sheets.Request(
        repeatCell: sheets.RepeatCellRequest(
          range: range(startRow: 0, endRow: 1),
          cell: sheets.CellData(
            userEnteredFormat: sheets.CellFormat(
              backgroundColor: purple,
              horizontalAlignment: 'CENTER',
              verticalAlignment: 'MIDDLE',
              wrapStrategy: 'WRAP',
              textFormat: sheets.TextFormat(
                bold: true,
                fontSize: 13,
                fontFamily: 'Merriweather',
                foregroundColor: white,
              ),
            ),
          ),
          fields: 'userEnteredFormat(backgroundColor,horizontalAlignment,'
              'verticalAlignment,wrapStrategy,textFormat)',
        ),
      ),
    ];

    if (rowCount == 0) {
      return requests;
    }

    requests.addAll(<sheets.Request>[
      // Tall data rows so covers and checkboxes are large.
      sheets.Request(
        updateDimensionProperties: sheets.UpdateDimensionPropertiesRequest(
          range: sheets.DimensionRange(
            sheetId: sheetId,
            dimension: 'ROWS',
            startIndex: 1,
            endIndex: lastRow,
          ),
          properties: sheets.DimensionProperties(pixelSize: _kDataRowHeight),
          fields: 'pixelSize',
        ),
      ),

      // Base data style.
      sheets.Request(
        repeatCell: sheets.RepeatCellRequest(
          range: range(startRow: 1, endRow: lastRow),
          cell: sheets.CellData(
            userEnteredFormat: sheets.CellFormat(
              verticalAlignment: 'MIDDLE',
              wrapStrategy: 'WRAP',
              padding: sheets.Padding(top: 6, bottom: 6, left: 10, right: 10),
              textFormat: sheets.TextFormat(
                fontSize: 12,
                fontFamily: 'Merriweather',
                foregroundColor: textColor,
              ),
            ),
          ),
          fields: 'userEnteredFormat(verticalAlignment,wrapStrategy,padding,textFormat)',
        ),
      ),

      // Title column: bold + slightly bigger.
      sheets.Request(
        repeatCell: sheets.RepeatCellRequest(
          range: range(
            startRow: 1,
            endRow: lastRow,
            startCol: _kTitleCol,
            endCol: _kTitleCol + 1,
          ),
          cell: sheets.CellData(
            userEnteredFormat: sheets.CellFormat(
              textFormat: sheets.TextFormat(
                bold: true,
                fontSize: 14,
                fontFamily: 'Merriweather',
                foregroundColor: textColor,
              ),
            ),
          ),
          fields: 'userEnteredFormat.textFormat',
        ),
      ),

      // Checkbox + cover columns: centred. Big font => big checkbox.
      sheets.Request(
        repeatCell: sheets.RepeatCellRequest(
          range: range(
            startRow: 1,
            endRow: lastRow,
            endCol: _kCoverCol + 1,
          ),
          cell: sheets.CellData(
            userEnteredFormat: sheets.CellFormat(
              horizontalAlignment: 'CENTER',
              verticalAlignment: 'MIDDLE',
              textFormat: sheets.TextFormat(
                fontSize: _kCheckboxFontSize,
                foregroundColor: purple,
              ),
            ),
          ),
          fields: 'userEnteredFormat(horizontalAlignment,verticalAlignment,textFormat)',
        ),
      ),

      // Checkbox validation.
      sheets.Request(
        setDataValidation: sheets.SetDataValidationRequest(
          range: range(
            startRow: 1,
            endRow: lastRow,
            endCol: _kCheckCol + 1,
          ),
          rule: sheets.DataValidationRule(
            condition: sheets.BooleanCondition(type: 'BOOLEAN'),
            showCustomUi: true,
          ),
        ),
      ),

      // Alternating row colours (header purple).
      sheets.Request(
        addBanding: sheets.AddBandingRequest(
          bandedRange: sheets.BandedRange(
            range: range(startRow: 0, endRow: lastRow),
            rowProperties: sheets.BandingProperties(
              headerColor: purple,
              firstBandColor: white,
              secondBandColor: lightPurple,
            ),
          ),
        ),
      ),

      // Thin dividers between rows.
      sheets.Request(
        updateBorders: sheets.UpdateBordersRequest(
          range: range(startRow: 0, endRow: lastRow),
          innerHorizontal: sheets.Border(style: 'SOLID', color: divider),
          bottom: sheets.Border(style: 'SOLID', color: divider),
        ),
      ),

      // Collected rows turn green + strikethrough.
      sheets.Request(
        addConditionalFormatRule: sheets.AddConditionalFormatRuleRequest(
          index: 0,
          rule: sheets.ConditionalFormatRule(
            ranges: <sheets.GridRange>[
              range(startRow: 1, endRow: lastRow, startCol: _kTitleCol),
            ],
            booleanRule: sheets.BooleanRule(
              condition: sheets.BooleanCondition(
                type: 'CUSTOM_FORMULA',
                values: <sheets.ConditionValue>[
                  sheets.ConditionValue(userEnteredValue: r'=$B2=TRUE'),
                ],
              ),
              format: sheets.CellFormat(
                backgroundColor: doneGreen,
                textFormat: sheets.TextFormat(
                  strikethrough: true,
                  foregroundColor: doneText,
                ),
              ),
            ),
          ),
        ),
      ),
      sheets.Request(
        addConditionalFormatRule: sheets.AddConditionalFormatRuleRequest(
          index: 1,
          rule: sheets.ConditionalFormatRule(
            ranges: <sheets.GridRange>[
              range(
                startRow: 1,
                endRow: lastRow,
                endCol: _kTitleCol,
              ),
            ],
            booleanRule: sheets.BooleanRule(
              condition: sheets.BooleanCondition(
                type: 'CUSTOM_FORMULA',
                values: <sheets.ConditionValue>[
                  sheets.ConditionValue(userEnteredValue: r'=$B2=TRUE'),
                ],
              ),
              format: sheets.CellFormat(backgroundColor: doneGreen),
            ),
          ),
        ),
      ),
    ]);

    return requests;
  }

  // ---------------------------------------------------------------------------
  // Cover images
  // ---------------------------------------------------------------------------

  /// Returns a map of bookId -> public image URL usable by `=IMAGE()`.
  ///
  /// HTTP(S) covers are used as-is. Base64 covers are uploaded (once, cached by
  /// content hash) to an app-owned Drive folder shared as "anyone can view".
  Future<Map<String, String>> _resolveCoverUrls(
    drive.DriveApi driveApi,
    SharedPreferences prefs,
    List<BookFairExportEntry> entries,
    String? rootFolderId,
  ) async {
    final Map<String, String> urls = <String, String>{};
    final Map<String, String> base64Covers = <String, String>{};

    for (final BookFairExportEntry e in entries) {
      final String? cover = e.book.cover;
      if (cover == null || cover.isEmpty) {
        continue;
      }
      if (cover.startsWith('http://') || cover.startsWith('https://')) {
        urls[e.book.id] = cover;
      } else {
        base64Covers[e.book.id] = cover;
      }
    }

    if (base64Covers.isEmpty) {
      return urls;
    }

    final String folderId = await _ensureFolder(
      driveApi,
      prefs,
      name: _kCoverFolderName,
      prefsKey: _kCoverFolderIdKey,
      parentId: rootFolderId,
      makePublic: true,
    );

    // Index existing cover files by bookId.
    final Map<String, _CoverFile> existing = <String, _CoverFile>{};
    String? pageToken;
    do {
      final drive.FileList list = await driveApi.files.list(
        q: "'$folderId' in parents and trashed = false",
        spaces: 'drive',
        pageSize: 1000,
        pageToken: pageToken,
        $fields: 'nextPageToken,files(id,appProperties)',
      );
      for (final drive.File f in list.files ?? <drive.File>[]) {
        final String? bookId = f.appProperties?['bookId'];
        if (bookId != null && f.id != null) {
          existing[bookId] = _CoverFile(f.id!, f.appProperties?['coverHash']);
        }
      }
      pageToken = list.nextPageToken;
    } while (pageToken != null);

    // Upload / update in small parallel batches.
    final List<MapEntry<String, String>> items = base64Covers.entries.toList();
    const int batchSize = 6;
    for (int i = 0; i < items.length; i += batchSize) {
      final Iterable<MapEntry<String, String>> batch = items.skip(i).take(batchSize);
      await Future.wait(
        batch.map((MapEntry<String, String> item) async {
          try {
            final String? fileId = await _upsertCover(
              driveApi,
              folderId,
              item.key,
              item.value,
              existing[item.key],
            );
            if (fileId != null) {
              urls[item.key] = 'https://lh3.googleusercontent.com/d/$fileId';
            }
          } catch (_) {
            // Skip this cover only.
          }
        }),
      );
    }

    // Clean up covers for books no longer on the list.
    final Iterable<_CoverFile> stale = existing.entries
        .where((MapEntry<String, _CoverFile> e) => !base64Covers.containsKey(e.key))
        .map((MapEntry<String, _CoverFile> e) => e.value);
    for (final _CoverFile f in stale) {
      try {
        await driveApi.files.delete(f.fileId);
      } catch (_) {
        // Non-fatal.
      }
    }

    return urls;
  }

  Future<String?> _upsertCover(
    drive.DriveApi driveApi,
    String folderId,
    String bookId,
    String cover,
    _CoverFile? existing,
  ) async {
    final String hash = _hash(cover);
    if (existing != null && existing.hash == hash) {
      return existing.fileId;
    }

    final String raw = cover.contains(',') && cover.startsWith('data:')
        ? cover.substring(cover.indexOf(',') + 1)
        : cover;
    final List<int> bytes = base64Decode(raw);
    final String mime = raw.startsWith('iVBORw0KGgo') ? 'image/png' : 'image/jpeg';
    final drive.Media media = drive.Media(
      Stream<List<int>>.fromIterable(<List<int>>[bytes]),
      bytes.length,
      contentType: mime,
    );

    if (existing != null) {
      await driveApi.files.update(
        drive.File()..appProperties = <String, String>{'coverHash': hash},
        existing.fileId,
        uploadMedia: media,
      );
      return existing.fileId;
    }

    final drive.File created = await driveApi.files.create(
      drive.File()
        ..name = '$bookId${mime == 'image/png' ? '.png' : '.jpg'}'
        ..parents = <String>[folderId]
        ..appProperties = <String, String>{'bookId': bookId, 'coverHash': hash},
      uploadMedia: media,
      $fields: 'id',
    );
    final String? id = created.id;
    if (id == null) {
      return null;
    }
    await _makePublicReadable(driveApi, id);
    return id;
  }

  /// Finds (by cached ID, then by name) or creates a Drive folder.
  ///
  /// When [parentId] is given, the folder is created inside it, and an
  /// existing folder located elsewhere is moved into it.
  Future<String> _ensureFolder(
    drive.DriveApi driveApi,
    SharedPreferences prefs, {
    required String name,
    required String prefsKey,
    String? parentId,
    bool makePublic = false,
  }) async {
    String? folderId;

    final String? storedId = prefs.getString(prefsKey);
    if (storedId != null) {
      try {
        final drive.File f = await driveApi.files.get(
          storedId,
          $fields: 'id,trashed',
        ) as drive.File;
        if (f.trashed != true) {
          folderId = storedId;
        }
      } catch (_) {
        // Fall through.
      }
    }

    if (folderId == null) {
      // Prefer a match inside the parent, otherwise any match (to migrate).
      final String nameQuery = "name = '$name' and mimeType = '$_kFolderMimeType' "
          'and trashed = false';
      if (parentId != null) {
        final drive.FileList inParent = await driveApi.files.list(
          q: "$nameQuery and '$parentId' in parents",
          spaces: 'drive',
          $fields: 'files(id)',
        );
        folderId = inParent.files?.firstOrNull?.id;
      }
      if (folderId == null) {
        final drive.FileList anywhere = await driveApi.files.list(
          q: nameQuery,
          spaces: 'drive',
          $fields: 'files(id)',
        );
        folderId = anywhere.files?.firstOrNull?.id;
      }
    }

    if (folderId == null) {
      final drive.File created = await driveApi.files.create(
        drive.File()
          ..name = name
          ..mimeType = _kFolderMimeType
          ..parents = parentId != null ? <String>[parentId] : null,
        $fields: 'id',
      );
      folderId = created.id;
      if (folderId == null) {
        throw Exception('Failed to create Drive folder "$name".');
      }
      if (makePublic) {
        await _makePublicReadable(driveApi, folderId);
      }
    } else if (parentId != null) {
      await _ensureInFolder(driveApi, folderId, parentId);
    }

    await prefs.setString(prefsKey, folderId);
    return folderId;
  }

  /// Moves [fileId] into [folderId] if it isn't already there.
  Future<void> _ensureInFolder(
    drive.DriveApi driveApi,
    String fileId,
    String folderId,
  ) async {
    try {
      final drive.File f = await driveApi.files.get(
        fileId,
        $fields: 'parents',
      ) as drive.File;
      final List<String> parents = f.parents ?? <String>[];
      if (parents.contains(folderId)) {
        return;
      }
      await driveApi.files.update(
        drive.File(),
        fileId,
        addParents: folderId,
        removeParents: parents.isEmpty ? null : parents.join(','),
      );
    } catch (_) {
      // Non-fatal — the file still works from its current location.
    }
  }

  Future<void> _makePublicReadable(drive.DriveApi driveApi, String fileId) async {
    try {
      await driveApi.permissions.create(
        drive.Permission()
          ..role = 'reader'
          ..type = 'anyone',
        fileId,
      );
    } catch (_) {
      // Ignore (already shared / blocked by domain policy).
    }
  }

  /// Stable 32-bit FNV-1a hash used to detect changed covers.
  String _hash(String input) {
    int hash = 0x811c9dc5;
    for (final int c in input.codeUnits) {
      hash ^= c;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return '${input.length}-${hash.toRadixString(16)}';
  }

  // ---------------------------------------------------------------------------
  // Pull
  // ---------------------------------------------------------------------------

  /// Reads the checkbox column from the shared sheet and marks ticked books as
  /// collected in the local repository.
  Future<BookFairSyncResult?> pullStatusUpdates(List<BookEntity> currentBooks) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? spreadsheetId = prefs.getString(_kSheetIdKey);
    if (spreadsheetId == null) {
      return null;
    }

    final GoogleAuthClient? client = await _buildAuthClient();
    if (client == null) {
      return null;
    }

    final sheets.SheetsApi sheetsApi = sheets.SheetsApi(client);

    sheets.ValueRange response;
    try {
      // Column A = ID, column B = Collected?
      response = await sheetsApi.spreadsheets.values.get(spreadsheetId, 'A2:B');
    } catch (e) {
      if (e.toString().contains('404')) {
        throw Exception(
          'Could not find the sheet in Google Drive. It may have been deleted. '
          'Please share the list again to create a new sheet.',
        );
      }
      rethrow;
    }

    final List<List<Object?>> sheetRows =
        (response.values ?? <List<Object?>>[]).cast<List<Object?>>();

    final List<String> updatedBookTitles = <String>[];
    final List<String> conflictBookTitles = <String>[];

    for (final List<Object?> row in sheetRows) {
      if (row.length < 2) {
        continue;
      }

      final String bookId = row[0]?.toString() ?? '';
      final bool isCollected = row[1]?.toString().toUpperCase() == 'TRUE';
      if (!isCollected || bookId.isEmpty) {
        continue;
      }

      final BookEntity? book = currentBooks
          .where((BookEntity b) => b.id == bookId)
          .cast<BookEntity?>()
          .firstOrNull;

      if (book == null) {
        continue;
      }
      if (book.collectionStatus == CollectionStatus.collected) {
        conflictBookTitles.add(book.title);
        continue;
      }

      final BookEntity updated = book.copyWith(
        collectionStatus: CollectionStatus.collected,
        collectedDate: Nullable<DateTime?>(book.collectedDate ?? DateTime.now()),
        lastUpdated: DateTime.now(),
      );

      await bookRepository.editBook(updated);
      updatedBookTitles.add(book.title);
    }

    return BookFairSyncResult(
      updatedBookTitles: updatedBookTitles,
      conflictBookTitles: conflictBookTitles,
    );
  }
}

@riverpod
BookFairSheetsService bookFairSheetsService(Ref ref) {
  final BookRepository bookRepository = ref.watch(bookRepositoryProvider);
  return BookFairSheetsService(bookRepository: bookRepository);
}
