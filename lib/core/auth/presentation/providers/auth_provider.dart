import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

part 'auth_provider.g.dart';

@riverpod
Stream<UserEntity?> authState(Ref ref) => ref.watch(fetchAuthStateChangesUseCaseProvider).call();

@riverpod
String? currentUid(Ref ref) => ref.watch(authStateProvider).value?.uid;

@riverpod
class AuthController extends _$AuthController {
  @override
  AsyncValue<void> build() => const AsyncValue<void>.data(null);

  Future<void> signInWithGoogle() async {
    state = const AsyncValue<void>.loading();
    state = await AsyncValue.guard(() => ref.read(signInWithGoogleUseCaseProvider).call());
  }

  Future<void> signOut() async {
    state = const AsyncValue<void>.loading();
    state = await AsyncValue.guard(() => ref.read(signOutUseCaseProvider).call());
  }
}
