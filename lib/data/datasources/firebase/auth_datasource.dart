import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Initializes GoogleSignIn. Must be called before other methods.
  Future<void> initialize() async {
    await _googleSignIn.initialize();
  }

  Future<UserCredential> signInWithGoogle() async {
    // Use Firebase Auth's Google provider - works on all platforms
    // including web where google_sign_in API has changed significantly
    final googleProvider = GoogleAuthProvider();

    // Request both ID and access tokens
    googleProvider.addScope('https://www.googleapis.com/auth/userinfo.email');
    googleProvider.addScope('https://www.googleapis.com/auth/userinfo.profile');

    // Use signInWithPopup for web compatibility
    // On mobile, this falls back to native flow
    return await _auth.signInWithPopup(googleProvider);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
}
