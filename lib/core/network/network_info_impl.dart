import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'network_info.dart';

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    // Fast check: is any network interface available?
    final result = await connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) return false;

    // Slow check: verify actual internet reachability via DNS lookup.
    // This catches cases like connected Wi-Fi with no internet (captive portal,
    // router issues) or Android emulators with no host network access.
    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      // Timeout or other error — assume disconnected.
      return false;
    }
  }
}