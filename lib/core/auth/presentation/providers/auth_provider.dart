import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

/// Grouped authentication use cases.
///
/// These providers bridge the domain layer use cases with the data layer repository.
final Provider<SignInWithGoogleUseCase> signInWithGoogleUseCaseProvider =
    Provider<SignInWithGoogleUseCase>(
      (Ref ref) => SignInWithGoogleUseCase(ref.watch(authRepositoryProvider)),
    );

final Provider<SignOutUseCase> signOutUseCaseProvider = Provider<SignOutUseCase>(
  (Ref ref) => SignOutUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<GetAuthStateChangesUseCase> getAuthStateChangesUseCaseProvider =
    Provider<GetAuthStateChangesUseCase>(
      (Ref ref) => GetAuthStateChangesUseCase(ref.watch(authRepositoryProvider)),
    );

/// Streams the current authenticated [UserEntity], or null when signed out.
final StreamProvider<UserEntity?> authStateProvider = StreamProvider<UserEntity?>(
  (Ref ref) => ref.watch(getAuthStateChangesUseCaseProvider).call(),
);

/// Controller for authentication-related UI actions.
final NotifierProvider<AuthController, AsyncValue<void>> authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

/// [AuthController] manages user actions like signing in and out.
/// It uses [AsyncValue] to track the current status of the operation (e.g., loading).
class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue<void>.data(null);

  /// Signs the user in with Google and updates the state.
  Future<void> signInWithGoogle() async {
    state = const AsyncValue<void>.loading();
    state = await AsyncValue.guard(() => ref.read(signInWithGoogleUseCaseProvider).call());
  }

  /// Signs the user out from both Firebase and Google.
  Future<void> signOut() async {
    state = const AsyncValue<void>.loading();
    state = await AsyncValue.guard(() => ref.read(signOutUseCaseProvider).call());
  }
}
