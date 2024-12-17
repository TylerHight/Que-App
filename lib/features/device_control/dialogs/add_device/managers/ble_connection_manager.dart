// lib/features/device_control/dialogs/add_device/managers/ble_connection_manager.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/add_device_state.dart';
import '../../../../../core/services/ble/ble_service.dart';
import '../../../../../core/utils/ble/ble_utils.dart';
import '../dialogs/bluetooth_enable_dialog.dart';

class BleConnectionManager {
  final BleService bleService;
  final Function(AddDeviceState) onStateChanged;
  final BuildContext context;
  final AddDeviceState _state = AddDeviceState();
  final BleUtils _bleUtils = BleUtils();

  StreamSubscription? _scanSubscription;
  Timer? _scanTimeoutTimer;

  static const Duration scanTimeout = Duration(seconds: 4);
  static const Duration retryDelay = Duration(seconds: 2);

  BleConnectionManager({
    required this.bleService,
    required this.onStateChanged,
    required this.context,
  });

  Future<void> initialize() async {
    await _checkBluetoothState();
  }

  Future<void> _checkBluetoothState() async {
    try {
      if (!await FlutterBluePlus.isSupported) {
        _state.setStatusMessage("Bluetooth not supported on this device");
        onStateChanged(_state);
        return;
      }

      if (!await FlutterBluePlus.isOn) {
        if (!context.mounted) return;

        final result = await showBluetoothEnableDialog(context);
        if (result == BluetoothEnableResult.enabled) {
          await startScan();
        } else {
          _state.setStatusMessage("Bluetooth is required for scanning");
          onStateChanged(_state);
        }
      } else {
        await startScan();
      }
    } catch (e) {
      _state.setStatusMessage("Error checking Bluetooth: $e");
      onStateChanged(_state);
    }
  }

  Future<void> startScan() async {
    if (_state.isScanning) return;

    _state.setScanning(true);
    _state.setStatusMessage("Scanning for devices...");
    onStateChanged(_state);

    try {
      final devices = await _bleUtils.startScan(timeout: scanTimeout);
      if (!context.mounted) return;

      _state.updateDevices(devices);
      _state.setLastScanTime(DateTime.now());
    } catch (e) {
      _state.setStatusMessage("Scan error: $e");
    } finally {
      _state.setScanning(false);
      onStateChanged(_state);
    }
  }

  void dispose() {
    _scanSubscription?.cancel();
    _scanTimeoutTimer?.cancel();
    FlutterBluePlus.stopScan();
  }
}