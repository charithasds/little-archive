import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/sync/data/services/backup_service.dart';
import '../../domain/usecases/settings_usecases.dart';

part 'settings_controller.g.dart';

@riverpod
class SettingsController extends _$SettingsController {
  @override
  FutureOr<void> build() {}

  Future<void> clearAllData() async {
    state = const AsyncValue<void>.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(clearAllDataUseCaseProvider).call();
    });
  }

  Future<bool> exportLocalBackup() async {
    state = const AsyncValue<void>.loading();
    final bool success = await ref.read(backupServiceProvider).exportLocalBackup();
    if (success) {
      state = const AsyncValue<void>.data(null);
    } else {
      state = AsyncValue<void>.error('Local export failed or cancelled.', StackTrace.current);
    }
    return success;
  }

  Future<bool> importLocalRestore() async {
    state = const AsyncValue<void>.loading();
    final AppDatabase db = ref.read(appDatabaseProvider);
    await db.close();
    
    final bool success = await ref.read(backupServiceProvider).importLocalRestore();
    if (success) {
      state = const AsyncValue<void>.data(null);
    } else {
      ref.invalidate(appDatabaseProvider);
      state = AsyncValue<void>.error('Local import failed or cancelled.', StackTrace.current);
    }
    return success;
  }

  Future<bool> backupToGoogleDrive() async {
    state = const AsyncValue<void>.loading();
    final bool success = await ref.read(backupServiceProvider).backupToGoogleDrive();
    if (success) {
      state = const AsyncValue<void>.data(null);
    } else {
      state = AsyncValue<void>.error('Google Drive backup failed. Please check network/auth.', StackTrace.current);
    }
    return success;
  }

  Future<bool> restoreFromGoogleDrive() async {
    state = const AsyncValue<void>.loading();
    final AppDatabase db = ref.read(appDatabaseProvider);
    await db.close();
    
    final bool success = await ref.read(backupServiceProvider).restoreFromGoogleDrive();
    if (success) {
      state = const AsyncValue<void>.data(null);
    } else {
      ref.invalidate(appDatabaseProvider);
      state = AsyncValue<void>.error('Google Drive restore failed or no backup found.', StackTrace.current);
    }
    return success;
  }
}
