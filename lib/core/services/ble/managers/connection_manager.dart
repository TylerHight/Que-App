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

  BleConnectionManager({
    required this.onStateChange,
    required this.onError,
  });

  Future<bool> connectWithRetry(BluetoothDevice device) async {
    int attempts = 0;

    while (attempts < _maxRetries) {
      try {
        await device.connect(
            timeout: BleConstants.CONNECTION_TIMEOUT,
            autoConnect: false
        );

        await Future.delayed(const Duration(milliseconds: 500));

        final state = await device.connectionState.first;
        if (state == BluetoothConnectionState.connected) {
          return true;
        }
      } catch (e) {
        attempts++;
        if (attempts < _maxRetries) {
          await Future.delayed(Duration(seconds: _retryDelays[attempts - 1]));
        }
      }
    }
    return false;
  }

  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }

  Future<bool> attemptRecovery(BluetoothDevice device) async {
    return await connectWithRetry(device);
  }

  Future<List<BluetoothDevice>> scanForDevices({
    required Duration timeout,
    List<Guid>? withServices,
    bool Function(BluetoothDevice)? filter,
  }) async {
    await FlutterBluePlus.startScan(
      timeout: timeout,
      withServices: withServices ?? [],
    );

    final results = await FlutterBluePlus.scanResults.first;
    final devices = results.map((r) => r.device).toList();

    if (filter != null) {
      return devices.where(filter).toList();
    }
    return devices;
  }

  void dispose() {
    // Clean up any resources
  }
}