import 'dart:async';

import 'package:app/core/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('initDependencies waits for GoogleSignIn initialization', () async {
    final platform = DelayedGoogleSignInPlatform();
    GoogleSignInPlatform.instance = platform;

    var completed = false;
    final initialization = initDependencies().then((_) {
      completed = true;
    });

    await Future<void>.delayed(Duration.zero);

    expect(platform.initCallCount, 1);
    expect(completed, isFalse);

    platform.completeInitialization();
    await initialization;

    expect(completed, isTrue);
  });
}

class DelayedGoogleSignInPlatform extends GoogleSignInPlatform {
  final Completer<void> _initializationCompleter = Completer<void>();
  int initCallCount = 0;

  void completeInitialization() {
    if (!_initializationCompleter.isCompleted) {
      _initializationCompleter.complete();
    }
  }

  @override
  Future<void> init(InitParameters params) {
    initCallCount += 1;
    return _initializationCompleter.future;
  }

  @override
  Future<AuthenticationResults?> attemptLightweightAuthentication(
    AttemptLightweightAuthenticationParameters params,
  ) async {
    return null;
  }

  @override
  bool supportsAuthenticate() => true;

  @override
  Future<AuthenticationResults> authenticate(AuthenticateParameters params) {
    throw UnimplementedError();
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
  Future<void> signOut(SignOutParams params) async {}

  @override
  Future<void> disconnect(DisconnectParams params) async {}
}
