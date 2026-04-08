import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../shared/data/services/connectivity_service.dart';
import '../../../shared/domain/error/exceptions.dart';

/// Data source for remote authentication operations using Firebase and Google.
class AuthRemoteDataSource {
  /// Creates an [AuthRemoteDataSource] with required services.
  AuthRemoteDataSource(this._firebaseAuth, this._googleSignIn, this._connectivityService);

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final ConnectivityService _connectivityService;

  /// Stream of [User] from FirebaseAuth.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Current [User] from FirebaseAuth.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Performs Google Sign-In and creates/updates the user document in Firestore.
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth;
      final AuthCredential credential;
      final UserCredential userCredential;

      if (googleUser == null) {
        return;
      }

      googleAuth = await googleUser.authentication;
      credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      userCredential = await _firebaseAuth.signInWithCredential(credential);

      await _createUserDoc(userCredential.user);
    }
  }

  /// Signs out from both Google and Firebase.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  /// Helper to create or update the user profile in Firestore.
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
