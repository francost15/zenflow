import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<void> signInWithGoogle();
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
  User? get currentUser;
}
