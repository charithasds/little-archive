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
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(scopes: ['email', 'profile']);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    ref.watch(firebaseAuthProvider),
    ref.watch(googleSignInProvider),
  );
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

// Use Cases
final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((
  ref,
) {
  return SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final getAuthStateChangesUseCaseProvider = Provider<GetAuthStateChangesUseCase>(
  (ref) {
    return GetAuthStateChangesUseCase(ref.watch(authRepositoryProvider));
  },
);

// State & Controller
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(getAuthStateChangesUseCaseProvider).call();
});

final authControllerProvider = NotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends Notifier<void> {
  @override
  void build() {
    // No state to maintain for now
  }

  Future<void> signInWithGoogle() async {
    final signInuseCase = ref.read(signInWithGoogleUseCaseProvider);
    await signInuseCase();
  }

  Future<void> signOut() async {
    final signOutUseCase = ref.read(signOutUseCaseProvider);
    await signOutUseCase();
  }
}
