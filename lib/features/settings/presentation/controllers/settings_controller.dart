import 'package:riverpod_annotation/riverpod_annotation.dart';
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

  Future<void> deleteAccount() async {
    state = const AsyncValue<void>.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteAccountUseCaseProvider).call();
    });
  }
}
