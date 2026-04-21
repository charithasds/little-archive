import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

part 'auth_provider.g.dart';

@riverpod
SignInWithGoogleUseCase signInWithGoogleUseCase(Ref ref) =>
    SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));

@riverpod
SignOutUseCase signOutUseCase(Ref ref) => SignOutUseCase(ref.watch(authRepositoryProvider));

@riverpod
GetAuthStateChangesUseCase getAuthStateChangesUseCase(Ref ref) =>
    GetAuthStateChangesUseCase(ref.watch(authRepositoryProvider));

final StreamProvider<UserEntity?> authStateProvider = StreamProvider<UserEntity?>(
  (Ref ref) => ref.watch(getAuthStateChangesUseCaseProvider).call(),
);

final Provider<String?> currentUidProvider = Provider<String?>(
  (Ref ref) => ref.watch(authStateProvider).value?.uid,
);

final NotifierProvider<AuthController, AsyncValue<void>> authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

class AuthController extends Notifier<AsyncValue<void>> {
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
