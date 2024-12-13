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

  BleConnectionManager({
    required this.onStateChange,
    required this.onError,
  });

  Future<bool> connectWithRetry(BluetoothDevice device) async {
    int attempts = 0;
    bool connected = false;

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
    // Monitor connection state
    _connectionSubscription?.cancel();
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
    _rssiCheckTimer?.cancel();
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
  }

  void _cleanupMonitoring() {
    _connectionSubscription?.cancel();
    _rssiCheckTimer?.cancel();
    _connectionSubscription = null;
    _rssiCheckTimer = null;
  }

  Future<void> disconnect(BluetoothDevice device) async {
    try {
      onStateChange(BleConnectionState.disconnecting);
      await device.disconnect();
    } finally {
      _cleanupMonitoring();
      onStateChange(BleConnectionState.disconnected);
    }
  }

  Future<bool> attemptRecovery(BluetoothDevice device) async {
    onError('Attempting connection recovery...');
    return await connectWithRetry(device);
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
    _cleanupMonitoring();
  }
}