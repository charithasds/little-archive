import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_auth_state_changes_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

// Data Sources and External Services
final Provider<FirebaseAuth> firebaseAuthProvider = Provider<FirebaseAuth>((Ref ref) {
  return FirebaseAuth.instance;
});

final Provider<GoogleSignIn> googleSignInProvider = Provider<GoogleSignIn>((Ref ref) {
  return GoogleSignIn(scopes: <String>['email', 'profile']);
});

final Provider<AuthRemoteDataSource> authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((Ref ref) {
  return AuthRemoteDataSource(
    ref.watch(firebaseAuthProvider),
    ref.watch(googleSignInProvider),
  );
});

// Repository
final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

// Use Cases
final Provider<SignInWithGoogleUseCase> signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((
  Ref ref,
) {
  return SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));
});

final Provider<SignOutUseCase> signOutUseCaseProvider = Provider<SignOutUseCase>((Ref ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final Provider<GetAuthStateChangesUseCase> getAuthStateChangesUseCaseProvider = Provider<GetAuthStateChangesUseCase>(
  (Ref ref) {
    return GetAuthStateChangesUseCase(ref.watch(authRepositoryProvider));
  },
);

// State & Controller
final StreamProvider<UserEntity?> authStateProvider = StreamProvider<UserEntity?>((Ref ref) {
  return ref.watch(getAuthStateChangesUseCaseProvider).call();
});

final NotifierProvider<AuthController, void> authControllerProvider = NotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends Notifier<void> {
  @override
  void build() {
    // No state to maintain for now
  }

  Future<void> signInWithGoogle() async {
    final SignInWithGoogleUseCase signInuseCase = ref.read(signInWithGoogleUseCaseProvider);
    await signInuseCase();
  }

  Future<void> signOut() async {
    final SignOutUseCase signOutUseCase = ref.read(signOutUseCaseProvider);
    await signOutUseCase();
  }
}
