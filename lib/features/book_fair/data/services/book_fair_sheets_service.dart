import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/shared/domain/enums/collection_status.dart';
import '../../../../core/shared/domain/utils/nullable.dart';
import '../../../../core/sync/data/services/backup_service.dart'
    show GoogleAuthClient;
import '../../../book/data/repositories/book_repository_impl.dart';
import '../../../book/domain/entities/book_entity.dart';
import '../../../book/domain/repositories/book_repository.dart';

part 'book_fair_sheets_service.g.dart';

const String _kSheetIdKey = 'book_fair_sheet_id';
const String _kSheetTitle = 'Little Archive Book Fair Shopping List';
const List<String> _kSheetsScopes = <String>[
  sheets.SheetsApi.spreadsheetsScope,
  drive.DriveApi.driveFileScope,
];

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

class BookFairSyncResult {
  const BookFairSyncResult({
    required this.updatedBookTitles,
    required this.conflictBookTitles,
  });

  final List<String> updatedBookTitles;
  final List<String> conflictBookTitles;
}

class BookFairSheetsService {
  BookFairSheetsService({required this.bookRepository});

  final BookRepository bookRepository;

  static String get _clientId => dotenv.env['GOOGLE_CLIENT_ID_WEB'] ?? '';

  Future<GoogleAuthClient?> _buildAuthClient() async {
    try {
      await GoogleSignIn.instance.initialize(
        clientId: _clientId,
        serverClientId: _clientId,
      );
      final GoogleSignInAccount user = await GoogleSignIn.instance.authenticate();

      final GoogleSignInClientAuthorization auth =
          await user.authorizationClient.authorizeScopes(_kSheetsScopes);

      return GoogleAuthClient(
        <String, String>{'Authorization': 'Bearer ${auth.accessToken}'},
      );
    } catch (_) {
      return null;
    }
  }

  /// Exports the book-fair shopping list to a Google Sheet.
  /// If a sheet was previously exported, it clears and reuses it to prevent
  /// generating multiple links. Converts the data into a formatted table.
  ///
  /// Sheet columns:
  ///   A (Hidden): Book ID (used for pull-sync)
  ///   B: Title
  ///   C: Creators
  ///   D: Publisher
  ///   E: Hall
  ///   F: Stall
  ///   G: Collected?
  Future<String?> exportListToSheet(List<BookFairExportEntry> entries) async {
    final GoogleAuthClient? client = await _buildAuthClient();
    if (client == null) {
      return null;
    }

    final sheets.SheetsApi sheetsApi = sheets.SheetsApi(client);
    final drive.DriveApi driveApi = drive.DriveApi(client);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? spreadsheetId = prefs.getString(_kSheetIdKey);

    const int sheetId = 0;

    // 1. Try to reuse and clear the existing sheet locally stored
    if (spreadsheetId != null) {
      try {
        final sheets.Spreadsheet ss = await sheetsApi.spreadsheets.get(spreadsheetId);
        
        final List<sheets.Request> clearRequests = <sheets.Request>[
          // Clear all cell data and formatting
          sheets.Request(
            updateCells: sheets.UpdateCellsRequest(
              range: sheets.GridRange(sheetId: sheetId),
              fields: '*',
            ),
          ),
          // Unhide column A if it was hidden, just to reset state
          sheets.Request(
            updateDimensionProperties: sheets.UpdateDimensionPropertiesRequest(
              range: sheets.DimensionRange(
                sheetId: sheetId,
                dimension: 'COLUMNS',
                startIndex: 0,
                endIndex: 1,
              ),
              properties: sheets.DimensionProperties(hiddenByUser: false),
              fields: 'hiddenByUser',
            ),
          ),
        ];

        // Delete existing bandings
        final sheets.Sheet sheet0 = ss.sheets?.firstWhere(
          (sheets.Sheet s) => s.properties?.sheetId == sheetId,
          orElse: () => sheets.Sheet(),
        ) ?? sheets.Sheet();

        if (sheet0.bandedRanges != null) {
          for (final sheets.BandedRange banding in sheet0.bandedRanges!) {
            if (banding.bandedRangeId != null) {
              clearRequests.add(
                sheets.Request(
                  deleteBanding: sheets.DeleteBandingRequest(
                    bandedRangeId: banding.bandedRangeId,
                  ),
                ),
              );
            }
          }
        }

        await sheetsApi.spreadsheets.batchUpdate(
          sheets.BatchUpdateSpreadsheetRequest(requests: clearRequests),
          spreadsheetId,
        );
      } catch (_) {
        spreadsheetId = null; // Fails if deleted/revoked
      }
    }

    // 2. Query Drive to see if it already exists to avoid creating "Name (1)"
    if (spreadsheetId == null) {
      try {
        final drive.FileList fileList = await driveApi.files.list(
          q: "name = '$_kSheetTitle' and mimeType = 'application/vnd.google-apps.spreadsheet' and trashed = false",
          spaces: 'drive',
        );
        if (fileList.files != null && fileList.files!.isNotEmpty) {
          spreadsheetId = fileList.files!.first.id;
          
          // Clear the found sheet before using it
          try {
            final sheets.Spreadsheet ss = await sheetsApi.spreadsheets.get(spreadsheetId!);
            final List<sheets.Request> clearRequests = <sheets.Request>[
              sheets.Request(
                updateCells: sheets.UpdateCellsRequest(
                  range: sheets.GridRange(sheetId: sheetId),
                  fields: '*',
                ),
              ),
              sheets.Request(
                updateDimensionProperties: sheets.UpdateDimensionPropertiesRequest(
                  range: sheets.DimensionRange(
                    sheetId: sheetId,
                    dimension: 'COLUMNS',
                    startIndex: 0,
                    endIndex: 1,
                  ),
                  properties: sheets.DimensionProperties(hiddenByUser: false),
                  fields: 'hiddenByUser',
                ),
              ),
            ];
            
            final sheets.Sheet sheet0 = ss.sheets?.firstWhere(
              (sheets.Sheet s) => s.properties?.sheetId == sheetId,
              orElse: () => sheets.Sheet(),
            ) ?? sheets.Sheet();

            if (sheet0.bandedRanges != null) {
              for (final sheets.BandedRange banding in sheet0.bandedRanges!) {
                if (banding.bandedRangeId != null) {
                  clearRequests.add(
                    sheets.Request(
                      deleteBanding: sheets.DeleteBandingRequest(
                        bandedRangeId: banding.bandedRangeId,
                      ),
                    ),
                  );
                }
              }
            }

            await sheetsApi.spreadsheets.batchUpdate(
              sheets.BatchUpdateSpreadsheetRequest(requests: clearRequests),
              spreadsheetId,
            );
          } catch (_) {
            // Ignore clear errors, just fall through
          }
        }
      } catch (_) {
        // Fall back to creating a new one if Drive query fails
      }
    }

    // 3. Create new if still missing
    if (spreadsheetId == null) {
      final sheets.Spreadsheet created = await sheetsApi.spreadsheets.create(
        sheets.Spreadsheet(
          properties: sheets.SpreadsheetProperties(title: _kSheetTitle),
        ),
      );
      if (created.spreadsheetId == null) {
        return null;
      }
      spreadsheetId = created.spreadsheetId;
    }

    // Capture non-null ID for all subsequent calls
    final String activeId = spreadsheetId!;

    try {
      await driveApi.permissions.create(
        drive.Permission()
          ..role = 'writer'
          ..type = 'anyone',
        activeId,
      );
    } catch (_) {
      // Ignore if permission already exists or fails
    }

    await prefs.setString(_kSheetIdKey, activeId);

    // Clear existing values in case the new list is shorter than the old one
    await sheetsApi.spreadsheets.values.clear(
      sheets.ClearValuesRequest(),
      activeId,
      'A:Z',
    );

    // 4. Write new rows
    final List<List<Object>> rows = <List<Object>>[
      <String>[
        'ID (Hidden)',
        'Title',
        'Creators',
        'Publisher',
        'Hall',
        'Stall',
        'Collected?',
      ],
      ...entries.map((BookFairExportEntry e) => <Object>[
            e.book.id,
            e.book.title,
            e.creators,
            e.publisherName,
            e.halls.join(', '),
            '${e.stallNo}  ${e.stallName}',
            false,
          ]),
    ];

    await sheetsApi.spreadsheets.values.update(
      sheets.ValueRange(values: rows),
      activeId,
      'A1',
      valueInputOption: 'RAW',
    );

    // 5. Format as table and hide Column A
    if (entries.isNotEmpty) {
      final sheets.Color purple = sheets.Color(red: 0.482, green: 0.122, blue: 0.635);
      final sheets.Color white = sheets.Color(red: 1.0, green: 1.0, blue: 1.0);
      final sheets.Color lightPurple = sheets.Color(red: 0.96, green: 0.93, blue: 0.98);

      await sheetsApi.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest(
          requests: <sheets.Request>[
            // Hide Column A (ID)
            sheets.Request(
              updateDimensionProperties: sheets.UpdateDimensionPropertiesRequest(
                range: sheets.DimensionRange(
                  sheetId: sheetId,
                  dimension: 'COLUMNS',
                  startIndex: 0,
                  endIndex: 1, // Column A
                ),
                properties: sheets.DimensionProperties(hiddenByUser: true),
                fields: 'hiddenByUser',
              ),
            ),
            // Checkbox for Collected? (Column G)
            sheets.Request(
              setDataValidation: sheets.SetDataValidationRequest(
                range: sheets.GridRange(
                  sheetId: sheetId,
                  startRowIndex: 1,
                  endRowIndex: entries.length + 1,
                  startColumnIndex: 6, // Column G
                  endColumnIndex: 7,
                ),
                rule: sheets.DataValidationRule(
                  condition: sheets.BooleanCondition(type: 'BOOLEAN'),
                  showCustomUi: true,
                ),
              ),
            ),
            // Bold header + purple background (Columns B to G)
            sheets.Request(
              repeatCell: sheets.RepeatCellRequest(
                range: sheets.GridRange(
                  sheetId: sheetId,
                  startRowIndex: 0,
                  endRowIndex: 1,
                  startColumnIndex: 1, // Start from B
                  endColumnIndex: 7,
                ),
                cell: sheets.CellData(
                  userEnteredFormat: sheets.CellFormat(
                    textFormat: sheets.TextFormat(bold: true, foregroundColor: white),
                    backgroundColor: purple,
                  ),
                ),
                fields: 'userEnteredFormat(textFormat,backgroundColor)',
              ),
            ),
            // Alternating colors (Banding) for data rows (Columns B to G)
            sheets.Request(
              addBanding: sheets.AddBandingRequest(
                bandedRange: sheets.BandedRange(
                  range: sheets.GridRange(
                    sheetId: sheetId,
                    startRowIndex: 1, // Exclude header from banding colors
                    endRowIndex: entries.length + 1,
                    startColumnIndex: 1, // Start from B
                    endColumnIndex: 7,
                  ),
                  rowProperties: sheets.BandingProperties(
                    firstBandColor: white,
                    secondBandColor: lightPurple,
                  ),
                ),
              ),
            ),
            // Auto-resize columns B to G
            sheets.Request(
              autoResizeDimensions: sheets.AutoResizeDimensionsRequest(
                dimensions: sheets.DimensionRange(
                  sheetId: sheetId,
                  dimension: 'COLUMNS',
                  startIndex: 1,
                  endIndex: 7,
                ),
              ),
            ),
          ],
        ),
        activeId,
      );
    }

    return 'https://docs.google.com/spreadsheets/d/$activeId/edit';
  }

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
      // Fetch A2:G — column A is ID, column G is Collected?
      response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        'A2:G',
      );
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
      if (row.length < 7) {
        continue;
      }

      final String bookId = row[0]?.toString() ?? '';
      final bool isCollected = row[6]?.toString().toUpperCase() == 'TRUE';

      if (!isCollected) {
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
        // Remote is collected, but local is ALSO collected. This is a conflict!
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
