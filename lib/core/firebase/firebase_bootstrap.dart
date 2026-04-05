import 'package:app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Inicializa Firebase según plataforma.
///
/// Android / iOS: configuración nativa (`google-services.json`, plist).
/// Web y escritorio: [DefaultFirebaseOptions] vía `--dart-define-from-file=.env`.
Future<void> initializeFirebaseApp() async {
  if (kIsWeb) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
    return;
  }

  final platform = defaultTargetPlatform;
  if (platform == TargetPlatform.android || platform == TargetPlatform.iOS) {
    await Firebase.initializeApp();
    return;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.desktop);
}
