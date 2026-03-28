import 'dart:async';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  static ConnectivityService? _instance;
  bool _isOnline = true;

  ConnectivityService._();

  static ConnectivityService get instance {
    _instance ??= ConnectivityService._();
    return _instance!;
  }

  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    // Simplified: assume online by default
    // In production, use connectivity_plus package
    _isOnline = true;
    notifyListeners();
  }

  void setOnline(bool value) {
    _isOnline = value;
    notifyListeners();
  }
}
