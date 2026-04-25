import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

part 'auth_usecases.g.dart';

class FetchAuthStateChangesUseCase {
  const FetchAuthStateChangesUseCase(this._repository);
  final AuthRepository _repository;

  Stream<UserEntity?> call() => _repository.authStateChanges;
}

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

@riverpod
FetchAuthStateChangesUseCase fetchAuthStateChangesUseCase(Ref ref) =>
    FetchAuthStateChangesUseCase(ref.watch(authRepositoryProvider));

@riverpod
SignInWithGoogleUseCase signInWithGoogleUseCase(Ref ref) =>
    SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));

@riverpod
SignOutUseCase signOutUseCase(Ref ref) => SignOutUseCase(ref.watch(authRepositoryProvider));
