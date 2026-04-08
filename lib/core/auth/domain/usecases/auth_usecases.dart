import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for handling Google Sign-In.
class SignInWithGoogleUseCase {
  /// Creates a [SignInWithGoogleUseCase].
  const SignInWithGoogleUseCase(this._repository);
  final AuthRepository _repository;

  /// Executes the sign-in operation.
  Future<void> call() async {
    await _repository.signInWithGoogle();
  }
}

/// Use case for signing out the user.
class SignOutUseCase {
  /// Creates a [SignOutUseCase].
  const SignOutUseCase(this._repository);
  final AuthRepository _repository;

  /// Executes the sign-out operation.
  Future<void> call() async {
    await _repository.signOut();
  }
}

/// Use case for listening to authentication state changes.
class GetAuthStateChangesUseCase {
  /// Creates a [GetAuthStateChangesUseCase].
  const GetAuthStateChangesUseCase(this._repository);
  final AuthRepository _repository;

  /// Returns a stream of the current authenticated user.
  Stream<UserEntity?> call() => _repository.authStateChanges;
}
