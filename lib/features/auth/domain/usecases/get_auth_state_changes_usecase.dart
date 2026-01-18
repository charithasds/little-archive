import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetAuthStateChangesUseCase {
  final AuthRepository _repository;

  GetAuthStateChangesUseCase(this._repository);

  Stream<UserEntity?> call() {
    return _repository.authStateChanges;
  }
}
