import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity service
class NetworkInfo {
  final Connectivity _connectivity = Connectivity();

  /// Check if device is connected to internet
  Future<bool> get isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Stream of connectivity changes
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivity.onConnectivityChanged;
}
