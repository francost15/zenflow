import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import 'package:app/data/datasources/firebase/auth_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RecordingFirebaseAuthPlatform firebaseAuthPlatform;
  late RecordingGoogleSignInPlatform googleSignInPlatform;

  setUpAll(() async {
    setupFirebaseCoreMocks();

    firebaseAuthPlatform = RecordingFirebaseAuthPlatform();
    googleSignInPlatform = RecordingGoogleSignInPlatform();

    FirebaseAuthPlatform.instance = firebaseAuthPlatform;
    GoogleSignInPlatform.instance = googleSignInPlatform;

    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'test-api-key',
            appId: 'test-app-id',
            messagingSenderId: 'test-sender-id',
            projectId: 'test-project-id',
          ),
        );
      } on FirebaseException catch (error) {
        if (error.code != 'duplicate-app') {
          rethrow;
        }
      }
    } else {
      Firebase.app();
    }
  });

  setUp(() {
    firebaseAuthPlatform.reset();
    googleSignInPlatform.reset();
  });

  test(
    'signInWithGoogle on mobile authenticates with GoogleSignIn and Firebase credential',
    () async {
      final datasource = AuthDatasource();

      await datasource.signInWithGoogle();

      expect(googleSignInPlatform.authenticateCallCount, 1);
      expect(firebaseAuthPlatform.signInWithProviderCallCount, 0);
      expect(firebaseAuthPlatform.lastCredential, isA<OAuthCredential>());

      final credential =
          firebaseAuthPlatform.lastCredential! as OAuthCredential;
      expect(credential.providerId, 'google.com');
      expect(credential.signInMethod, 'google.com');
    },
  );
}

class RecordingGoogleSignInPlatform extends GoogleSignInPlatform {
  int authenticateCallCount = 0;
  int signOutCallCount = 0;

  void reset() {
    authenticateCallCount = 0;
    signOutCallCount = 0;
  }

  @override
  Future<void> init(InitParameters params) async {}

  @override
  Future<AuthenticationResults?> attemptLightweightAuthentication(
    AttemptLightweightAuthenticationParameters params,
  ) async {
    return null;
  }

  @override
  bool supportsAuthenticate() => true;

  @override
  Future<AuthenticationResults> authenticate(
    AuthenticateParameters params,
  ) async {
    authenticateCallCount += 1;
    return const AuthenticationResults(
      user: GoogleSignInUserData(
        email: 'test@example.com',
        id: 'google-user-id',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.png',
      ),
      authenticationTokens: AuthenticationTokenData(idToken: 'google-id-token'),
    );
  }

  @override
  bool authorizationRequiresUserInteraction() => false;

  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
    ClientAuthorizationTokensForScopesParameters params,
  ) async {
    return null;
  }

  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
    ServerAuthorizationTokensForScopesParameters params,
  ) async {
    return null;
  }

  @override
  Future<void> signOut(SignOutParams params) async {
    signOutCallCount += 1;
  }

  @override
  Future<void> disconnect(DisconnectParams params) async {}
}

class RecordingFirebaseAuthPlatform extends FirebaseAuthPlatform {
  RecordingFirebaseAuthPlatform();

  final StreamController<UserPlatform?> _authStateController =
      StreamController<UserPlatform?>.broadcast();

  AuthCredential? lastCredential;
  int signInWithProviderCallCount = 0;
  int signOutCallCount = 0;
  UserPlatform? _currentUser;

  void reset() {
    lastCredential = null;
    signInWithProviderCallCount = 0;
    signOutCallCount = 0;
    _currentUser = null;
  }

  @override
  FirebaseAuthPlatform delegateFor({
    required FirebaseApp app,
    Persistence? persistence,
  }) {
    return this;
  }

  @override
  FirebaseAuthPlatform setInitialValues({
    PigeonUserDetails? currentUser,
    String? languageCode,
  }) {
    return this;
  }

  @override
  UserPlatform? get currentUser => _currentUser;

  @override
  set currentUser(UserPlatform? userPlatform) {
    _currentUser = userPlatform;
  }

  @override
  Stream<UserPlatform?> authStateChanges() => _authStateController.stream;

  @override
  Future<UserCredentialPlatform> signInWithCredential(
    AuthCredential credential,
  ) async {
    lastCredential = credential;
    return _EmptyUserCredentialPlatform(this);
  }

  @override
  Future<UserCredentialPlatform> signInWithProvider(
    AuthProvider provider,
  ) async {
    signInWithProviderCallCount += 1;
    return _EmptyUserCredentialPlatform(this);
  }

  @override
  Future<void> signOut() async {
    signOutCallCount += 1;
    _currentUser = null;
    _authStateController.add(null);
  }
}

class _EmptyUserCredentialPlatform extends UserCredentialPlatform {
  _EmptyUserCredentialPlatform(FirebaseAuthPlatform auth) : super(auth: auth);
}
