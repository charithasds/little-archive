import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/sync/data/services/backup_service.dart';
import 'settings_usecase_providers.dart';

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
    this.progress,
  });

  final AsyncValue<void> status;
  final SettingsOperation? currentOperation;
  final double? progress;

  SettingsState copyWith({
    AsyncValue<void>? status,
    SettingsOperation? currentOperation,
    double? progress,
  }) => SettingsState(
    status: status ?? this.status,
    currentOperation: currentOperation ?? this.currentOperation,
    progress: progress ?? this.progress,
  );
}

@riverpod
class SettingsController extends _$SettingsController {
  @override
  SettingsState build() => const SettingsState(status: AsyncValue<void>.data(null));

  Future<void> clearAllData() async {
    final ClearAllDataUseCase clearAllDataUseCase = ref.read(clearAllDataUseCaseProvider);
    state = const SettingsState(
      status: AsyncValue<void>.loading(),
      currentOperation: SettingsOperation.clearData,
      progress: 0.0,
    );
    await Future<void>.delayed(Duration.zero);
    final AsyncValue<void> result = await AsyncValue.guard(() async {
      await clearAllDataUseCase(
        onProgress: (double p) => state = state.copyWith(progress: p),
      );
    });
    state = SettingsState(
      status: result,
    );
  }

  Future<bool> exportLocalBackup() async {
    final BackupService backupService = ref.read(backupServiceProvider);
    state = const SettingsState(
      status: AsyncValue<void>.loading(),
      currentOperation: SettingsOperation.exportLocal,
    );
    await Future<void>.delayed(Duration.zero);
    final bool success = await backupService.exportLocalBackup(
      onProgress: (double p) => state = state.copyWith(progress: p),
    );
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
    final AppDatabase db = ref.read(appDatabaseProvider);
    final BackupService backupService = ref.read(backupServiceProvider);
    state = const SettingsState(
      status: AsyncValue<void>.loading(),
      currentOperation: SettingsOperation.importLocal,
    );
    await Future<void>.delayed(Duration.zero);
    await db.close();

    final bool success = await backupService.importLocalRestore(
      onProgress: (double p) => state = state.copyWith(progress: p),
    );
    if (success) {
      state = const SettingsState(status: AsyncValue<void>.data(null));
    } else {
      if (ref.mounted) {
        ref.invalidate(appDatabaseProvider);
      }
      state = SettingsState(
        status: AsyncValue<void>.error('Local import failed or cancelled.', StackTrace.current),
      );
    }
    return success;
  }

  Future<bool> backupToGoogleDrive() async {
    final BackupService backupService = ref.read(backupServiceProvider);
    state = const SettingsState(
      status: AsyncValue<void>.loading(),
      currentOperation: SettingsOperation.backupDrive,
    );
    await Future<void>.delayed(Duration.zero);
    final bool success = await backupService.backupToGoogleDrive(
      onProgress: (double p) => state = state.copyWith(progress: p),
    );
    if (success) {
      state = const SettingsState(status: AsyncValue<void>.data(null));
    } else {
      state = SettingsState(
        status: AsyncValue<void>.error(
          'Google Drive backup failed. Please check network/auth.',
          StackTrace.current,
        ),
      );
    }
    return success;
  }

  Future<bool> restoreFromGoogleDrive() async {
    final AppDatabase db = ref.read(appDatabaseProvider);
    final BackupService backupService = ref.read(backupServiceProvider);
    state = const SettingsState(
      status: AsyncValue<void>.loading(),
      currentOperation: SettingsOperation.restoreDrive,
    );
    await Future<void>.delayed(Duration.zero);
    await db.close();

    final bool success = await backupService.restoreFromGoogleDrive(
      onProgress: (double p) => state = state.copyWith(progress: p),
    );
    if (success) {
      state = const SettingsState(status: AsyncValue<void>.data(null));
    } else {
      if (ref.mounted) {
        ref.invalidate(appDatabaseProvider);
      }
      state = SettingsState(
        status: AsyncValue<void>.error(
          'Google Drive restore failed or no backup found.',
          StackTrace.current,
        ),
      );
    }
    return success;
  }
}
