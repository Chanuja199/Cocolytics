import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // One-time check — is device online right now?
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }

  // Stream — listen for connectivity changes
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) => results.any(
        (r) =>
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.wifi ||
            r == ConnectivityResult.ethernet,
      ),
    );
  }
}
