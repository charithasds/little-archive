import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../shared/data/services/connectivity_service.dart';
import '../../../shared/domain/error/exceptions.dart';

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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      await _createUserDoc(userCredential.user);
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
