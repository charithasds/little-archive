import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../shared/presentation/providers/connectivity_provider.dart';
import '../../../shared/presentation/providers/firebase_provider.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_auth_state_changes_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

final Provider<GoogleSignIn> googleSignInProvider = Provider<GoogleSignIn>(
  (Ref ref) => GoogleSignIn(scopes: <String>['email', 'profile']),
);

final Provider<AuthRemoteDataSource> authRemoteDataSourceProvider =
    Provider<AuthRemoteDataSource>(
      (Ref ref) => AuthRemoteDataSource(
        ref.watch(firebaseAuthProvider),
        ref.watch(googleSignInProvider),
        ref.watch(connectivityServiceProvider),
      ),
    );

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>(
  (Ref ref) => AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider)),
);

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

final NotifierProvider<AuthController, void> authControllerProvider =
    NotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends Notifier<void> {
  @override
  void build() {}

  Future<void> signInWithGoogle() async {
    await ref.read(signInWithGoogleUseCaseProvider)();
  }

  Future<void> signOut() async {
    await ref.read(signOutUseCaseProvider)();
  }
}
