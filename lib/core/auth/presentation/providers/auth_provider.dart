import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/data/services/connectivity_service.dart';
import '../../../shared/presentation/providers/connectivity_provider.dart';
import '../../../shared/presentation/providers/firebase_provider.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

part 'auth_provider.g.dart';

@riverpod
GoogleSignIn _googleSignIn(Ref ref) => GoogleSignIn.instance;

@riverpod
AuthRemoteDataSource _authRemoteDataSource(Ref ref) {
  final FirebaseAuth firebaseAuth = ref.watch(firebaseAuthProvider);
  final GoogleSignIn googleSignIn = ref.watch(_googleSignInProvider);
  final ConnectivityService connectivityService = ref.watch(connectivityServiceProvider);

  return AuthRemoteDataSource(firebaseAuth, googleSignIn, connectivityService);
}

@riverpod
AuthRepository _authRepository(Ref ref) {
  final AuthRemoteDataSource remoteDataSource = ref.watch(_authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
}

@riverpod
FetchAuthStateChangesUseCase fetchAuthStateChangesUseCase(Ref ref) =>
    FetchAuthStateChangesUseCase(ref.watch(_authRepositoryProvider));

@riverpod
SignInWithGoogleUseCase signInWithGoogleUseCase(Ref ref) =>
    SignInWithGoogleUseCase(ref.watch(_authRepositoryProvider));

@riverpod
SignOutUseCase signOutUseCase(Ref ref) => SignOutUseCase(ref.watch(_authRepositoryProvider));

final StreamProvider<UserEntity?> authStateProvider = StreamProvider<UserEntity?>(
  (Ref ref) => ref.watch(fetchAuthStateChangesUseCaseProvider).call(),
);

final Provider<String?> currentUidProvider = Provider<String?>(
  (Ref ref) => ref.watch(authStateProvider).value?.uid,
);

final NotifierProvider<AuthController, AsyncValue<void>> authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue<void>.data(null);

  Future<void> signInWithGoogle() async {
    state = const AsyncValue<void>.loading();
    state = await AsyncValue.guard(() => ref.read(signInWithGoogleUseCaseProvider).call());
  }

  Future<void> signOut() async {
    state = const AsyncValue<void>.loading();
    state = await AsyncValue.guard(() => ref.read(signOutUseCaseProvider).call());
  }
}
