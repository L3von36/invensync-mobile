import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/datasources/remote/api_client.dart';

class ConnectivityState {
  final bool isOnline;
  final bool isConnected;
  final DateTime? lastHeartbeat;
  final bool isChecking;

  const ConnectivityState({
    this.isOnline = true,
    this.isConnected = true,
    this.lastHeartbeat,
    this.isChecking = false,
  });

  ConnectivityState copyWith({
    bool? isOnline,
    bool? isConnected,
    DateTime? lastHeartbeat,
    bool? isChecking,
  }) {
    return ConnectivityState(
      isOnline: isOnline ?? this.isOnline,
      isConnected: isConnected ?? this.isConnected,
      lastHeartbeat: lastHeartbeat ?? this.lastHeartbeat,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}

class ConnectivityService {
  final ApiClient _api;
  final _controller = StreamController<ConnectivityState>.broadcast();
  final _connectivity = Connectivity();

  ConnectivityState _state = const ConnectivityState();
  DateTime? _lastHeartbeatTime;
  bool _heartbeatInProgress = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _periodicTimer;
  bool _started = false;

  static const _heartbeatDebounceMs = 10000;
  static const _periodicIntervalMs = 30000;
  static const _heartbeatTimeoutSeconds = 5;

  ConnectivityService(this._api);

  ConnectivityState get state => _state;
  Stream<ConnectivityState> get stream => _controller.stream;

  void startMonitoring() {
    if (_started) return;
    _started = true;

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final hasConnection =
          results.isNotEmpty && !results.contains(ConnectivityResult.none);
      if (hasConnection) {
        _updateState(isOnline: true);
        // Don't debounce on reconnect
        _lastHeartbeatTime = null;
        checkNow();
      } else {
        _updateState(isOnline: false, isConnected: false);
      }
    });

    // Initial check
    _connectivity.checkConnectivity().then((results) {
      final hasConnection =
          results.isNotEmpty && !results.contains(ConnectivityResult.none);
      if (hasConnection) {
        _updateState(isOnline: true);
        checkNow();
      } else {
        _updateState(isOnline: false, isConnected: false);
      }
    });

    // Periodic heartbeat
    _periodicTimer = Timer.periodic(
      const Duration(milliseconds: _periodicIntervalMs),
      (_) {
        if (_state.isOnline) {
          _debouncedHeartbeat();
        }
      },
    );
  }

  void stopMonitoring() {
    _subscription?.cancel();
    _periodicTimer?.cancel();
    _started = false;
  }

  Future<bool> checkNow() async {
    if (_heartbeatInProgress) return _state.isConnected;

    _heartbeatInProgress = true;
    _updateState(isChecking: true);

    try {
      final result = await _api.ping();
      final now = DateTime.now();
      _lastHeartbeatTime = now;

      _updateState(
        isConnected: result,
        lastHeartbeat: now,
        isChecking: false,
      );
      return result;
    } catch (_) {
      final now = DateTime.now();
      _lastHeartbeatTime = now;

      _updateState(
        isConnected: false,
        lastHeartbeat: now,
        isChecking: false,
      );
      return false;
    } finally {
      _heartbeatInProgress = false;
    }
  }

  Future<bool> _debouncedHeartbeat() async {
    if (_lastHeartbeatTime != null) {
      final elapsed =
          DateTime.now().difference(_lastHeartbeatTime!).inMilliseconds;
      if (elapsed < _heartbeatDebounceMs) {
        return _state.isConnected;
      }
    }
    return checkNow();
  }

  void _updateState({
    bool? isOnline,
    bool? isConnected,
    DateTime? lastHeartbeat,
    bool? isChecking,
  }) {
    _state = _state.copyWith(
      isOnline: isOnline,
      isConnected: isConnected,
      lastHeartbeat: lastHeartbeat,
      isChecking: isChecking,
    );
    _controller.add(_state);
  }

  void dispose() {
    stopMonitoring();
    _controller.close();
  }
}