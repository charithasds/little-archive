import '../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {

  SignInWithGoogleUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call() async {
    return _repository.signInWithGoogle();
  }
}
