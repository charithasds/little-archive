import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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
  Future<bool> exportLocalBackup() async {
    try {
      final File dbFile = await _getDatabaseFile();
      if (!dbFile.existsSync()) {

        return false;
      }

      final Uint8List bytes = await dbFile.readAsBytes();
      final String? savePath = await FilePicker.saveFile(
        dialogTitle: 'Save database backup',
        fileName: 'little_archive_backup.db',
        bytes: bytes,
      );
      // savePath is null only when the user cancels the picker.
      return savePath != null;
    } catch (e) {

      return false;
    }
  }

  /// Restores the local database from a user-selected backup file.
  ///
  /// Uses [withData: true] to load the file bytes directly through the
  /// FilePicker content URI — no raw path permission needed on Android.
  Future<bool> importLocalRestore() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(withData: true);

      if (result == null || result.files.single.bytes == null) {
        return false; // User cancelled or file unreadable
      }

      final File dbFile = await _getDatabaseFile();

      if (dbFile.existsSync()) {
        await dbFile.delete();
      }
      await dbFile.writeAsBytes(result.files.single.bytes!);
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
  Future<bool> backupToGoogleDrive() async {
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

      final drive.Media media = drive.Media(dbFile.openRead(), dbFile.lengthSync());

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
  Future<bool> restoreFromGoogleDrive() async {
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

      final String fileId = existingFiles.files!.first.id!;
      final drive.Media response =
          await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia)
              as drive.Media;

      final List<int> dataBytes = <int>[];
      await response.stream.forEach(dataBytes.addAll);

      final File dbFile = await _getDatabaseFile();
      if (dbFile.existsSync()) {
        await dbFile.delete();
      }
      await dbFile.writeAsBytes(dataBytes);
      return true;
    } catch (e) {
      return false;
    }
  }
}

@riverpod
BackupService backupService(Ref ref) => BackupService();
