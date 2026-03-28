import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Initializes GoogleSignIn. Must be called before other methods on web.
  Future<void> initialize() async {
    if (kIsWeb) {
      await _googleSignIn.initialize();
    }
    // On mobile, Firebase Auth doesn't need google_sign_in initialization
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
      // On mobile, use Firebase Auth's Google Sign-In
      // This uses the Google Play Services / Firebase UI flow
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('https://www.googleapis.com/auth/userinfo.email');
      googleProvider.addScope(
        'https://www.googleapis.com/auth/userinfo.profile',
      );

      // Use signInWithRedirect for mobile to get native experience
      return await _auth.signInWithProvider(googleProvider);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {
        // Ignore sign-out errors from google_sign_in
      }
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
}
