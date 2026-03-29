import 'package:app/data/datasources/firebase/auth_datasource.dart';
import 'package:app/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<void> signInWithGoogle() => _datasource.signInWithGoogle();

  @override
  Future<void> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signUpWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Stream<User?> get authStateChanges => _datasource.authStateChanges;

  @override
  User? get currentUser => _datasource.currentUser;

  FirebaseAuth get _auth => FirebaseAuth.instance;
}
