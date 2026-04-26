import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/settings_repository_impl.dart';

part 'settings_controller.g.dart';

@riverpod
class SettingsController extends _$SettingsController {
  @override
  FutureOr<void> build() {}

  Future<void> clearAllData() async {
    state = const AsyncValue<void>.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(settingsRepositoryProvider).clearAllData();
    });
  }
}
