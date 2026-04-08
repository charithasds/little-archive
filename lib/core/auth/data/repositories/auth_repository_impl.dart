import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../shared/presentation/providers/connectivity_provider.dart';
import '../../../shared/presentation/providers/firebase_provider.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

/// Implementation of [AuthRepository] using Firebase Auth and Google Sign-In.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates an [AuthRepositoryImpl] with the given [AuthRemoteDataSource].
  AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;

  @override
  Stream<UserEntity?> get authStateChanges =>
      _dataSource.authStateChanges.map((User? firebaseUser) {
        if (firebaseUser == null) {
          return null;
        }

        return UserModel.fromFirebase(firebaseUser);
      });

  @override
  UserEntity? get currentUser {
    final User? firebaseUser = _dataSource.currentUser;

    if (firebaseUser == null) {
      return null;
    }

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

/// Provider for [GoogleSignIn] configuration.
final Provider<GoogleSignIn> googleSignInProvider = Provider<GoogleSignIn>(
  (Ref ref) => GoogleSignIn(scopes: <String>['email', 'profile']),
);

/// Provider for [AuthRemoteDataSource].
final Provider<AuthRemoteDataSource> authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (Ref ref) => AuthRemoteDataSource(
    ref.watch(firebaseAuthProvider),
    ref.watch(googleSignInProvider),
    ref.watch(connectivityServiceProvider),
  ),
);

/// Provider for the authentication repository implementation.
final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>(
  (Ref ref) => AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider)),
);
