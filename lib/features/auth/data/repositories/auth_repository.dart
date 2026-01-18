import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Stream<UserEntity?> get authStateChanges {
    return _dataSource.authStateChanges.map((firebaseUser) {
      if (firebaseUser == null) return null;
      return UserModel.fromFirebase(firebaseUser);
    });
  }

  @override
  UserEntity? get currentUser {
    final firebaseUser = _dataSource.currentUser;
    if (firebaseUser == null) return null;
    return UserModel.fromFirebase(firebaseUser);
  }

  @override
  Future<void> signInWithGoogle() async {
    await _dataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }
}
