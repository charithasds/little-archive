import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backup_service.g.dart';

class GoogleAuthClient extends http.BaseClient {
  GoogleAuthClient(this._headers);
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

class BackupService {
  static String get _clientId => dotenv.env['GOOGLE_CLIENT_ID_WEB'] ?? '';

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Get the active Drift database file path.
  Future<File> _getDatabaseFile() async {
    final Directory dbFolder = await getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, 'little_archive.db'));
  }

  // --- LOCAL BACKUP & RESTORE ---

  /// Exports the local database file.
  ///
  /// Uses [FilePicker.saveFile] with raw bytes on all platforms, which on
  /// Android opens the SAF ACTION_CREATE_DOCUMENT picker — the user can choose
  /// any writable destination (Downloads, Drive, SD card, etc.) without needing
  /// any storage permissions.
  Future<bool> exportLocalBackup({void Function(double)? onProgress}) async {
    try {
      final File dbFile = await _getDatabaseFile();
      if (!dbFile.existsSync()) {

        return false;
      }

      int bytesRead = 0;
      final int totalBytes = dbFile.lengthSync();
      final BytesBuilder builder = BytesBuilder(copy: false);
      
      await for (final List<int> chunk in dbFile.openRead()) {
        builder.add(chunk);
        bytesRead += chunk.length;
        if (totalBytes > 0) {
          onProgress?.call((bytesRead / totalBytes) * 0.9); // Reserve 10% for the save operation
        }
      }
      
      final Uint8List bytes = builder.toBytes();
      final String? savePath = await FilePicker.saveFile(
        dialogTitle: 'Save database backup',
        fileName: 'little_archive_backup.db',
        bytes: bytes,
      );
      
      if (savePath != null) {
        onProgress?.call(1.0);
      }
      
      // savePath is null only when the user cancels the picker.
      return savePath != null;
    } catch (e) {

      return false;
    }
  }

  /// Restores the local database from a user-selected backup file.
  ///
  /// Uses [withReadStream: true] to read the file in chunks instead of loading
  /// the entire file into memory with [withData: true], avoiding OutOfMemoryError.
  Future<bool> importLocalRestore({void Function(double)? onProgress}) async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(withReadStream: true);

      if (result == null || result.files.single.readStream == null) {
        return false; // User cancelled or file unreadable
      }

      final File dbFile = await _getDatabaseFile();

      if (dbFile.existsSync()) {
        await dbFile.delete();
      }
      
      final IOSink sink = dbFile.openWrite();
      int bytesWritten = 0;
      final int totalBytes = result.files.single.size;
      
      final Stream<List<int>> progressStream = result.files.single.readStream!.map((List<int> chunk) {
        bytesWritten += chunk.length;
        if (totalBytes > 0) {
          onProgress?.call(bytesWritten / totalBytes);
        }
        return chunk;
      });
      
      await sink.addStream(progressStream);
      await sink.close();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- GOOGLE DRIVE BACKUP & RESTORE ---

  /// Authenticate and authorize standard Google Sign-In with Drive scopes.
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(clientId: _clientId, serverClientId: _clientId);
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      return googleUser;
    } catch (e) {
      return null;
    }
  }

  /// Disconnect/Sign-out Google account.
  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  /// Helper to get authenticated client headers.
  Future<Map<String, String>?> _getAuthHeaders() async {
    try {
      await _googleSignIn.initialize(clientId: _clientId, serverClientId: _clientId);
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInClientAuthorization auth = await googleUser.authorizationClient
          .authorizeScopes(const <String>['https://www.googleapis.com/auth/drive.appdata']);

      return <String, String>{'Authorization': 'Bearer ${auth.accessToken}'};
    } catch (e) {
      return null;
    }
  }

  /// Backs up the Drift SQLite database to the private Drive AppData folder.
  Future<bool> backupToGoogleDrive({void Function(double)? onProgress}) async {
    try {
      final Map<String, String>? authHeaders = await _getAuthHeaders();
      if (authHeaders == null) {
        return false;
      }

      final GoogleAuthClient client = GoogleAuthClient(authHeaders);
      final drive.DriveApi driveApi = drive.DriveApi(client);

      final File dbFile = await _getDatabaseFile();
      if (!dbFile.existsSync()) {
        return false;
      }

      // Find any existing backup in appDataFolder
      final drive.FileList existingFiles = await driveApi.files.list(
        q: "name = 'little_archive_backup.db' and 'appDataFolder' in parents and trashed = false",
        spaces: 'appDataFolder',
      );

      final drive.File driveFile = drive.File()
        ..name = 'little_archive_backup.db';

      int bytesUploaded = 0;
      final int totalBytes = dbFile.lengthSync();
      
      final Stream<List<int>> progressStream = dbFile.openRead().map((List<int> chunk) {
        bytesUploaded += chunk.length;
        if (totalBytes > 0) {
          onProgress?.call(bytesUploaded / totalBytes);
        }
        return chunk;
      });

      final drive.Media media = drive.Media(progressStream, totalBytes);

      if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
        // Overwrite existing backup file
        final String fileId = existingFiles.files!.first.id!;
        await driveApi.files.update(driveFile, fileId, uploadMedia: media);
      } else {
        // Create new backup file
        driveFile.parents = <String>['appDataFolder'];
        await driveApi.files.create(driveFile, uploadMedia: media);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Restores the Drift database from the private Drive AppData folder.
  Future<bool> restoreFromGoogleDrive({void Function(double)? onProgress}) async {
    try {
      final Map<String, String>? authHeaders = await _getAuthHeaders();
      if (authHeaders == null) {
        return false;
      }

      final GoogleAuthClient client = GoogleAuthClient(authHeaders);
      final drive.DriveApi driveApi = drive.DriveApi(client);

      // Search for backup in appDataFolder
      final drive.FileList existingFiles = await driveApi.files.list(
        q: "name = 'little_archive_backup.db' and 'appDataFolder' in parents and trashed = false",
        spaces: 'appDataFolder',
      );

      if (existingFiles.files == null || existingFiles.files!.isEmpty) {
        return false; // No backup file found
      }

      final drive.File fileMeta = existingFiles.files!.first;
      final String fileId = fileMeta.id!;
      
      // Need to fetch file size because fullMedia download doesn't include it in Media.length if not known
      final drive.File fullMeta = await driveApi.files.get(fileId, $fields: 'size') as drive.File;
      final int totalBytes = int.tryParse(fullMeta.size ?? '0') ?? 0;

      final drive.Media response =
          await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia)
              as drive.Media;

      final File dbFile = await _getDatabaseFile();
      if (dbFile.existsSync()) {
        await dbFile.delete();
      }
      
      final IOSink sink = dbFile.openWrite();
      int bytesWritten = 0;
      
      final Stream<List<int>> progressStream = response.stream.map((List<int> chunk) {
        bytesWritten += chunk.length;
        if (totalBytes > 0) {
          onProgress?.call(bytesWritten / totalBytes);
        }
        return chunk;
      });
      
      await sink.addStream(progressStream);
      await sink.close();
      
      return true;
    } catch (e) {
      return false;
    }
  }
}

@riverpod
BackupService backupService(Ref ref) => BackupService();
