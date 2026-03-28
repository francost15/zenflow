import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Initializes GoogleSignIn. Must be called before other methods.
  Future<void> initialize() async {
    await _googleSignIn.initialize();
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      // On web, use signInWithPopup
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('https://www.googleapis.com/auth/userinfo.email');
      googleProvider.addScope(
        'https://www.googleapis.com/auth/userinfo.profile',
      );
      return await _auth.signInWithPopup(googleProvider);
    } else {
      // On mobile, use google_sign_in.authenticate() to get ID token
      final googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }
      // Get the ID token from authentication
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
}
