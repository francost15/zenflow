import 'package:app/app/app.dart';
import 'package:app/core/di/injection.dart';
import 'package:app/core/firebase/firebase_bootstrap.dart';
import 'package:app/core/utils/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  await initializeFirebaseApp();
  await ConnectivityService.instance.initialize();
  await initDependencies();
  runApp(const ZenFlowApp());
}
