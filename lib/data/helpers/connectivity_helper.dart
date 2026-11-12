import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';


class ConnectivityHelper {
  bool hasInternet = true;
  StreamSubscription? _subscription;
  StreamController<bool>? _connectivityChangeStreamController;

  static ConnectivityHelper? _instance;

  ConnectivityHelper._private();

  factory ConnectivityHelper() => _instance ??= ConnectivityHelper._private();

  Stream<bool> get onConnectivityChanged => (_connectivityChangeStreamController ??= StreamController<bool>.broadcast()).stream;

  void initialize() {
    Connectivity().checkConnectivity().then(_onConnectivityChange);
    _subscription = Connectivity().onConnectivityChanged.listen(_onConnectivityChange);
  }

  void _onConnectivityChange(List<ConnectivityResult> result) {
    hasInternet = result != ConnectivityResult.none;
    _connectivityChangeStreamController?.add(hasInternet);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _connectivityChangeStreamController?.close();
    _connectivityChangeStreamController = null;
  }
}