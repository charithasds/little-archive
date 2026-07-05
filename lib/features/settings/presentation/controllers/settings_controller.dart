import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/sync/data/services/backup_service.dart';
import '../../domain/usecases/settings_usecases.dart';

part 'settings_controller.g.dart';

enum SettingsOperation {
  exportLocal,
  importLocal,
  backupDrive,
  restoreDrive,
  clearData,
}

class SettingsState {
  const SettingsState({
    required this.status,
    this.currentOperation,
  });

  final AsyncValue<void> status;
  final SettingsOperation? currentOperation;

  SettingsState copyWith({
    AsyncValue<void>? status,
    SettingsOperation? currentOperation,
  }) => SettingsState(
    status: status ?? this.status,
    currentOperation: currentOperation ?? this.currentOperation,
  );
}

@riverpod
class SettingsController extends _$SettingsController {
  @override
  SettingsState build() => const SettingsState(status: AsyncValue<void>.data(null));

  Future<void> clearAllData() async {
    state = const SettingsState(
      status: AsyncValue<void>.loading(),
      currentOperation: SettingsOperation.clearData,
    );
    await Future<void>.delayed(Duration.zero);
    final AsyncValue<void> result = await AsyncValue.guard(() async {
      await ref.read(clearAllDataUseCaseProvider).call();
    });
    state = SettingsState(
      status: result,
    );
  }

  Future<bool> exportLocalBackup() async {
    state = const SettingsState(
      status: AsyncValue<void>.loading(),
      currentOperation: SettingsOperation.exportLocal,
    );
    await Future<void>.delayed(Duration.zero);
    final bool success = await ref.read(backupServiceProvider).exportLocalBackup();
    if (success) {
      state = const SettingsState(status: AsyncValue<void>.data(null));
    } else {
      state = SettingsState(
        status: AsyncValue<void>.error('Local export failed or cancelled.', StackTrace.current),
      );
    }
    return success;
  }

  Future<bool> importLocalRestore() async {
    state = const SettingsState(
      status: AsyncValue<void>.loading(),
      currentOperation: SettingsOperation.importLocal,
    );
    await Future<void>.delayed(Duration.zero);
    final AppDatabase db = ref.read(appDatabaseProvider);
    await db.close();
    
    final bool success = await ref.read(backupServiceProvider).importLocalRestore();
    if (success) {
      state = const SettingsState(status: AsyncValue<void>.data(null));
    } else {
      ref.invalidate(appDatabaseProvider);
      state = SettingsState(
        status: AsyncValue<void>.error('Local import failed or cancelled.', StackTrace.current),
      );
    }
    return success;
  }

  Future<bool> backupToGoogleDrive() async {
    state = const SettingsState(
      status: AsyncValue<void>.loading(),
      currentOperation: SettingsOperation.backupDrive,
    );
    await Future<void>.delayed(Duration.zero);
    final bool success = await ref.read(backupServiceProvider).backupToGoogleDrive();
    if (success) {
      state = const SettingsState(status: AsyncValue<void>.data(null));
    } else {
      state = SettingsState(
        status: AsyncValue<void>.error('Google Drive backup failed. Please check network/auth.', StackTrace.current),
      );
    }
    return success;
  }

  Future<bool> restoreFromGoogleDrive() async {
    state = const SettingsState(
      status: AsyncValue<void>.loading(),
      currentOperation: SettingsOperation.restoreDrive,
    );
    await Future<void>.delayed(Duration.zero);
    final AppDatabase db = ref.read(appDatabaseProvider);
    await db.close();
    
    final bool success = await ref.read(backupServiceProvider).restoreFromGoogleDrive();
    if (success) {
      state = const SettingsState(status: AsyncValue<void>.data(null));
    } else {
      ref.invalidate(appDatabaseProvider);
      state = SettingsState(
        status: AsyncValue<void>.error('Google Drive restore failed or no backup found.', StackTrace.current),
      );
    }
    return success;
  }
}
