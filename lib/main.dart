import 'package:app/app/app.dart';
import 'package:app/core/di/injection.dart';
import 'package:app/core/utils/connectivity_service.dart';
import 'package:app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ConnectivityService.instance.initialize();
  await initDependencies();
  runApp(const ZenFlowApp());
}
