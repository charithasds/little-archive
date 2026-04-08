import '../entities/user_entity.dart';

/// Repository interface for authentication operations.
abstract class AuthRepository {
  /// Stream of [UserEntity] that emits whenever the authentication state changes.
  Stream<UserEntity?> get authStateChanges;

  /// Returns the currently authenticated user, or null if none.
  UserEntity? get currentUser;

  /// Initiates the Google Sign-In process.
  Future<void> signInWithGoogle();

  /// Signs out the current user.
  Future<void> signOut();
}
