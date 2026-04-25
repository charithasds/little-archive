import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/data/services/connectivity_service.dart';
import '../../../shared/domain/error/exceptions.dart';
import '../../../shared/presentation/providers/firebase_provider.dart';

part 'auth_remote_data_source.g.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._firebaseAuth, this._googleSignIn, this._connectivityService);

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final ConnectivityService _connectivityService;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> signInWithGoogle() async {
    final bool isConnected = await _connectivityService.isConnected();

    if (!isConnected) {
      throw const NoConnectionException(
        'Sign in requires an internet connection. Please check your network and try again.',
      );
    }

    if (kIsWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final UserCredential userCredential = await _firebaseAuth.signInWithPopup(googleProvider);

      await _createUserDoc(userCredential.user);
    } else {
      await _googleSignIn.initialize(
        clientId: '959815093644-mdq9akkmrevrafqb863cup4go3ss5jud.apps.googleusercontent.com',
      );

      try {
        final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
        final GoogleSignInAuthentication googleAuth;
        final AuthCredential credential;
        final UserCredential userCredential;

        googleAuth = googleUser.authentication;

        final GoogleSignInClientAuthorization auth = await googleUser.authorizationClient
            .authorizeScopes(const <String>['email', 'profile']);

        credential = GoogleAuthProvider.credential(
          accessToken: auth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _firebaseAuth.signInWithCredential(credential);

        await _createUserDoc(userCredential.user);
      } catch (e) {
        if (e.toString().contains('cancel')) {
          return;
        }
        rethrow;
      }
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<void> _createUserDoc(User? user) async {
    if (user == null) {
      return;
    }

    final DocumentReference<Map<String, dynamic>> userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final DocumentSnapshot<Map<String, dynamic>> docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set(<String, dynamic>{
        'email': user.email,
        'id': user.uid,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } else {
      await userDoc.update(<String, dynamic>{'lastLogin': FieldValue.serverTimestamp()});
    }
  }
}

@riverpod
GoogleSignIn googleSignIn(Ref ref) => GoogleSignIn.instance;

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final FirebaseAuth firebaseAuth = ref.watch(firebaseAuthProvider);
  final GoogleSignIn gSignIn = ref.watch(googleSignInProvider);
  final ConnectivityService connectivityService = ref.watch(connectivityServiceProvider);

  return AuthRemoteDataSource(firebaseAuth, gSignIn, connectivityService);
}
