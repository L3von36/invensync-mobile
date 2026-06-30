import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

enum ConnectivityStatus { online, offline, checking }

class ConnectivityService {
  final Logger _logger = Logger();
  final Connectivity _connectivity = Connectivity();

  final _statusController =
      StreamController<ConnectivityStatus>.broadcast();
  final _isOnlineController = StreamController<bool>.broadcast();

  Stream<ConnectivityStatus> get statusStream => _statusController.stream;
  Stream<bool> get isOnlineStream => _isOnlineController.stream;

  ConnectivityStatus _status = ConnectivityStatus.checking;
  bool _isOnline = false;

  ConnectivityStatus get status => _status;
  bool get isOnline => _isOnline;

  Timer? _heartbeatTimer;
  Timer? _debounceTimer;

  void init() {
    _checkInitialConnectivity();
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    _startHeartbeat();
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateFromResult(result);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _updateFromResult(results);
    });
  }

  void _updateFromResult(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.any((r) =>
        r != ConnectivityResult.none && r != ConnectivityResult.other);

    if (wasOnline != _isOnline) {
      _status = _isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline;
      _statusController.add(_status);
      _isOnlineController.add(_isOnline);
      _logger.i('Connectivity changed: $_status');
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _heartbeat(),
    );
  }

  Future<void> _heartbeat() async {
    // Ping the API server to verify actual internet
    // This is handled by the sync engine's pull attempt
    _statusController.add(ConnectivityStatus.checking);
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    _debounceTimer?.cancel();
    _statusController.close();
    _isOnlineController.close();
  }
}