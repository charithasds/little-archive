import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call() async {
    await _repository.signInWithGoogle();
  }
}

class SignOutUseCase {
  const SignOutUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call() async {
    await _repository.signOut();
  }
}

class GetAuthStateChangesUseCase {
  const GetAuthStateChangesUseCase(this._repository);
  final AuthRepository _repository;

  Stream<UserEntity?> call() => _repository.authStateChanges;
}
