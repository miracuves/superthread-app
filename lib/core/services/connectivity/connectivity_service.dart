import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;
  ConnectivityResult _currentResult = ConnectivityResult.none;
  bool _isOnline = false;

  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isOnline => _isOnline;
  ConnectivityResult get currentResult => _currentResult;

  Future<void> init() async {
    _currentResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(_currentResult);

    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (_currentResult != result) {
        _currentResult = result;
        _updateConnectionStatus(result);
      }
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    if (!wasOnline && _isOnline) {
      debugPrint('🌐 Connection restored');
    } else if (wasOnline && !_isOnline) {
      debugPrint('📶 Connection lost');
    }

    _connectionController.add(_isOnline);
  }

  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _currentResult = result;
    _updateConnectionStatus(result);
    return _isOnline;
  }

  String get connectionStatusText {
    switch (_currentResult) {
      case ConnectivityResult.wifi:
        return 'Connected to WiFi';
      case ConnectivityResult.mobile:
        return 'Connected to Mobile';
      case ConnectivityResult.ethernet:
        return 'Connected to Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Connected via Bluetooth';
      case ConnectivityResult.vpn:
        return 'Connected via VPN';
      case ConnectivityResult.other:
        return 'Connected via Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }

  bool get isConnectionSlow {
    return _currentResult == ConnectivityResult.mobile;
  }

  void dispose() {
    _subscription?.cancel();
    _connectionController.close();
  }
}