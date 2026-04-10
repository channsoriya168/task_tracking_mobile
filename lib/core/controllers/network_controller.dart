import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/network/network_info_impl.dart';

enum ConnectionStatus { connected, disconnected, reconnected }

class NetworkController extends GetxController {
  final NetworkInfoImpl networkInfo;

  NetworkController(this.networkInfo);

  final RxBool isConnected = true.obs;
  final Rx<ConnectionStatus> connectionStatus = ConnectionStatus.connected.obs;

  StreamSubscription? _subscription;
  Timer? _restoreDebounce;
  Timer? _reconnectedTimer;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnectivity();
    _initNetworkListener();
  }

  @override
  void onClose() {
    _restoreDebounce?.cancel();
    _reconnectedTimer?.cancel();
    _subscription?.cancel();
    super.onClose();
  }

  // ── Initial check ─────────────────────────────────────────────────────────

  Future<void> _checkInitialConnectivity() async {
    try {
      final connected = await networkInfo.isConnected;
      isConnected.value = connected;
      connectionStatus.value =
          connected ? ConnectionStatus.connected : ConnectionStatus.disconnected;
    } catch (_) {}
  }

  // ── Stream listener (Android / iOS only) ──────────────────────────────────

  void _initNetworkListener() {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;

    // .handleError() intercepts MissingPluginException thrown inside Flutter's
    // platform channel async machinery — runZonedGuarded cannot reach it.
    _subscription = networkInfo.connectivity.onConnectivityChanged
        .handleError((_) {})
        .listen(_onConnectivityChanged, cancelOnError: false);
  }

  void _onConnectivityChanged(dynamic status) {
    _restoreDebounce?.cancel();

    final hasNetwork = status != ConnectivityResult.none;
    if (!hasNetwork) {
      _markDisconnected();
    } else {
      // Debounce: wait 1.5 s then verify with a real DNS lookup.
      _restoreDebounce = Timer(const Duration(milliseconds: 1500), () async {
        try {
          final connected = await networkInfo.isConnected;
          if (connected) {
            _markConnected();
          } else {
            _markDisconnected();
          }
        } catch (_) {
          _markConnected();
        }
      });
    }
  }

  // ── Called by Dio interceptor ─────────────────────────────────────────────

  void onConnectionError() {
    _restoreDebounce?.cancel();
    _markDisconnected();
  }

  void onConnectionRestored() {
    if (!isConnected.value) {
      _restoreDebounce?.cancel();
      _markConnected();
    }
  }

  // ── Public retry (called from NoInternetSheet) ───────────────────────────

  Future<void> retry() => _checkInitialConnectivity();

  // ── Private helpers ───────────────────────────────────────────────────────

  void _markDisconnected() {
    _reconnectedTimer?.cancel();
    isConnected.value = false;
    connectionStatus.value = ConnectionStatus.disconnected;
  }

  void _markConnected() {
    isConnected.value = true;
    if (connectionStatus.value == ConnectionStatus.disconnected) {
      // Brief "Back online" flash before hiding the banner.
      connectionStatus.value = ConnectionStatus.reconnected;
      _reconnectedTimer?.cancel();
      _reconnectedTimer = Timer(const Duration(seconds: 2), () {
        connectionStatus.value = ConnectionStatus.connected;
      });
    } else {
      connectionStatus.value = ConnectionStatus.connected;
    }
  }
}