// lib/core/services/ble/managers/connection_manager.dart

import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../ble_types.dart';
import '../../../constants/ble_constants.dart';

class BleConnectionManager {
  final StateChangeCallback onStateChange;
  final ErrorCallback onError;
  final _retryDelays = [1, 2, 3]; // Seconds between retries
  final _maxRetries = 3;

  StreamSubscription? _connectionSubscription;
  Timer? _rssiCheckTimer;
  Timer? _keepAliveTimer;
  Timer? _connectionWatchdog;
  BluetoothDevice? _currentDevice;

  static const Duration keepAliveInterval = Duration(seconds: 15);
  static const Duration watchdogTimeout = Duration(seconds: 70);

  BleConnectionManager({
    required this.onStateChange,
    required this.onError,
  });

  Future<bool> connectWithRetry(BluetoothDevice device) async {
    int attempts = 0;
    bool connected = false;
    _currentDevice = device;

    while (attempts < _maxRetries && !connected) {
      try {
        onStateChange(BleConnectionState.connecting);

        await device.connect(
            timeout: BleConstants.CONNECTION_TIMEOUT,
            autoConnect: false
        );

        // Wait for connection stabilization
        await Future.delayed(const Duration(milliseconds: 500));

        // Check connection state
        final state = await device.connectionState.first;
        if (state == BluetoothConnectionState.connected) {
          connected = true;

          // Setup connection monitoring
          _setupConnectionMonitoring(device);

          onStateChange(BleConnectionState.connected);
          return true;
        }
      } catch (e) {
        attempts++;
        onError('Connection attempt $attempts failed: $e');

        if (attempts < _maxRetries) {
          await Future.delayed(Duration(seconds: _retryDelays[attempts - 1]));
        }
      }
    }

    onStateChange(BleConnectionState.disconnected);
    return false;
  }

  void _setupConnectionMonitoring(BluetoothDevice device) {
    _cleanupMonitoring();

    // Monitor connection state
    _connectionSubscription = device.connectionState.listen(
            (BluetoothConnectionState state) {
          if (state == BluetoothConnectionState.disconnected) {
            onStateChange(BleConnectionState.disconnected);
            _cleanupMonitoring();
          }
        },
        onError: (error) {
          onError('Connection monitoring error: $error');
          onStateChange(BleConnectionState.disconnected);
          _cleanupMonitoring();
        }
    );

    // Monitor signal strength periodically
    _rssiCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final rssi = await device.readRssi();
        if (rssi < BleConstants.MIN_RSSI_THRESHOLD) {
          onError('Warning: Weak signal strength (RSSI: $rssi)');
        }
      } catch (e) {
        // Ignore RSSI read errors
      }
    });

    // Setup keep-alive timer
    _keepAliveTimer = Timer.periodic(keepAliveInterval, (_) {
      _sendKeepAlive(device);
    });

    // Setup connection watchdog
    _resetWatchdog();
  }

  Future<void> _sendKeepAlive(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      final service = services.firstWhere(
            (s) => s.uuid.toString().toLowerCase() == BleConstants.LED_SERVICE_UUID.toLowerCase(),
      );

      final characteristic = service.characteristics.firstWhere(
            (c) => c.uuid.toString().toLowerCase() == BleConstants.SWITCH_CHARACTERISTIC_UUID.toLowerCase(),
      );

      await characteristic.write([0], withoutResponse: true);
      _resetWatchdog();
    } catch (e) {
      onError('Keep-alive failed: $e');
    }
  }

  void _resetWatchdog() {
    _connectionWatchdog?.cancel();
    _connectionWatchdog = Timer(watchdogTimeout, () {
      onError('Connection watchdog timeout');
      if (_currentDevice != null) {
        disconnect(_currentDevice!);
      }
    });
  }

  Future<void> disconnect(BluetoothDevice device) async {
    try {
      onStateChange(BleConnectionState.disconnecting);
      await device.disconnect();
    } finally {
      _cleanupMonitoring();
      _currentDevice = null;
      onStateChange(BleConnectionState.disconnected);
    }
  }

  void _cleanupMonitoring() {
    _connectionSubscription?.cancel();
    _rssiCheckTimer?.cancel();
    _keepAliveTimer?.cancel();
    _connectionWatchdog?.cancel();
    _connectionSubscription = null;
    _rssiCheckTimer = null;
    _keepAliveTimer = null;
    _connectionWatchdog = null;
  }

  Future<bool> attemptRecovery(BluetoothDevice device) async {
    onError('Attempting connection recovery...');
    _cleanupMonitoring();

    try {
      // First try to disconnect cleanly
      await device.disconnect();
      await Future.delayed(const Duration(seconds: 1));

      // Attempt to reconnect
      return await connectWithRetry(device);
    } catch (e) {
      onError('Recovery failed: $e');
      return false;
    }
  }

  Future<List<BluetoothDevice>> scanForDevices({
    required Duration timeout,
    List<Guid>? withServices,
    bool Function(BluetoothDevice)? filter,
  }) async {
    try {
      // Stop any ongoing scan
      await FlutterBluePlus.stopScan();

      await FlutterBluePlus.startScan(
        timeout: timeout,
        withServices: withServices ?? [],
        androidScanMode: AndroidScanMode.lowLatency,
      );

      final results = await FlutterBluePlus.scanResults.first;
      final devices = results
          .where((r) => r.device.platformName.contains(BleConstants.DEVICE_NAME_PREFIX))
          .where((r) => r.rssi >= BleConstants.MIN_RSSI_THRESHOLD)
          .map((r) => r.device)
          .toList();

      if (filter != null) {
        return devices.where(filter).toList();
      }
      return devices;
    } catch (e) {
      onError('Scan failed: $e');
      return [];
    } finally {
      await FlutterBluePlus.stopScan();
    }
  }

  void dispose() {
    if (_currentDevice != null) {
      disconnect(_currentDevice!);
    }
    _cleanupMonitoring();
  }
}