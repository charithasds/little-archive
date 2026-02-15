import '../repositories/auth_repository.dart';

class SignOutUseCase {
  SignOutUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call() async => _repository.signOut();
}
