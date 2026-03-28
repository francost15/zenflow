import 'dart:async';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  static ConnectivityService? _instance;
  bool _isOnline = true;
  StreamSubscription<ConnectivityResult>? _subscription;

  ConnectivityService._();

  static ConnectivityService get instance {
    _instance ??= ConnectivityService._();
    return _instance!;
  }

  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    _isOnline = await _checkConnectivity();
    notifyListeners();

    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      _isOnline = _checkResult(result);
      notifyListeners();
    });
  }

  bool _checkResult(List<ConnectivityResult> results) {
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet,
    );
  }

  Future<bool> _checkConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return _checkResult(results);
    } catch (e) {
      return true;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
