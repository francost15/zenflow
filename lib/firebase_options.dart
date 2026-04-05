// Opciones explícitas solo para Web y escritorio (Linux/Windows/macOS), vía
// --dart-define / --dart-define-from-file=.env
//
// En Android e iOS, usa `Firebase.initializeApp()` sin `options`: Firebase lee
// `android/app/google-services.json` y `ios/Runner/GoogleService-Info.plist`.
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase desde variables de entorno (Web y targets de escritorio).
class DefaultFirebaseOptions {
  /// Web: requiere `.env` + `flutter run --dart-define-from-file=.env`
  static FirebaseOptions get web => _webLikeOptions();

  /// Linux / Windows / macOS: mismas variables que Web (app web del mismo proyecto).
  static FirebaseOptions get desktop => _webLikeOptions();

  static FirebaseOptions _webLikeOptions() {
    const apiKey = String.fromEnvironment(
      'FIREBASE_WEB_API_KEY',
      defaultValue: '',
    );
    const appId = String.fromEnvironment(
      'FIREBASE_WEB_APP_ID',
      defaultValue: '',
    );
    const messagingSenderId = String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '',
    );
    const projectId = String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: '',
    );
    const authDomain = String.fromEnvironment(
      'FIREBASE_WEB_AUTH_DOMAIN',
      defaultValue: '',
    );
    const storageBucket = String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: '',
    );
    const measurementId = String.fromEnvironment(
      'FIREBASE_WEB_MEASUREMENT_ID',
      defaultValue: '',
    );
    _ensureFirebaseEnv(
      platform: 'Web/escritorio',
      required: {
        'FIREBASE_WEB_API_KEY': apiKey,
        'FIREBASE_WEB_APP_ID': appId,
        'FIREBASE_MESSAGING_SENDER_ID': messagingSenderId,
        'FIREBASE_PROJECT_ID': projectId,
        'FIREBASE_WEB_AUTH_DOMAIN': authDomain,
        'FIREBASE_STORAGE_BUCKET': storageBucket,
      },
    );
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: authDomain,
      storageBucket: storageBucket,
      measurementId: measurementId.isEmpty ? null : measurementId,
    );
  }

  static void _ensureFirebaseEnv({
    required String platform,
    required Map<String, String> required,
  }) {
    final missing = required.entries
        .where((e) => e.value.isEmpty)
        .map((e) => e.key)
        .toList();
    if (missing.isEmpty) {
      return;
    }
    throw UnsupportedError(
      'Firebase ($platform): faltan dart-defines: ${missing.join(', ')}. '
      'Copia .env.example a .env, rellena los valores y ejecuta por ejemplo:\n'
      '  flutter run --dart-define-from-file=.env',
    );
  }
}
