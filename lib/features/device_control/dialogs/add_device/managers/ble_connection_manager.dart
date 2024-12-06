// lib/features/device_control/dialogs/add_device/managers/ble_connection_manager.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:que_app/core/services/ble/ble_service.dart';
import 'package:que_app/core/utils/ble/ble_utils.dart';
import 'package:que_app/features/device_control/dialogs/add_device/models/add_device_state.dart';
import 'package:que_app/features/device_control/dialogs/add_device/dialogs/bluetooth_enable_dialog.dart';

class BleConnectionManager {
  final BleService bleService;
  final Function(AddDeviceState) onStateChanged;
  final BuildContext context;
  final AddDeviceState _state = AddDeviceState();
  final BleUtils _bleUtils = BleUtils();

  StreamSubscription? _deviceStateSubscription;
  StreamSubscription? _connectionStatusSubscription;
  StreamSubscription? _bluetoothStateSubscription;
  StreamSubscription? _scanSubscription;
  Timer? _autoScanTimer;

  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration autoScanInterval = Duration(seconds: 10);

  BleConnectionManager({
    required this.bleService,
    required this.onStateChanged,
    required this.context,
  });

  Future<void> initialize() async {
    _setupSubscriptions();
    await _checkBluetoothState();
    _startAutoScan();
  }

  Future<void> _checkBluetoothState() async {
    try {
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        _state.setStatusMessage("Bluetooth not supported on this device");
        onStateChanged(_state);
        return;
      }

      final isOn = await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
      if (!isOn) {
        await _handleBluetoothDisabled();
        return;
      }

      startScan();
    } catch (e) {
      _state.setStatusMessage("Error checking Bluetooth: $e");
      onStateChanged(_state);
    }
  }

  Future<void> _handleBluetoothDisabled() async {
    if (!context.mounted) return;

    final result = await showBluetoothEnableDialog(context);

    if (result == BluetoothEnableResult.enabled) {
      _state.setStatusMessage("Starting scan...");
      onStateChanged(_state);
      await startScan();
    } else {
      _state.setStatusMessage("Bluetooth is required for scanning");
      onStateChanged(_state);
    }
  }

  void _setupSubscriptions() {
    _deviceStateSubscription = bleService.deviceStateStream.listen(
          (message) {
        _state.setStatusMessage(message);
        onStateChanged(_state);
      },
      onError: (error) {
        _state.setStatusMessage("Error: $error");
        _state.setConnecting(false);
        onStateChanged(_state);
      },
    );

    _connectionStatusSubscription = bleService.connectionStatusStream.listen(
          (isConnected) {
        if (!isConnected && _state.isConnecting) {
          _state.setStatusMessage("Device disconnected");
          _state.setConnecting(false);
          onStateChanged(_state);
          _handleConnectionFailure();
        }
      },
    );

    _bluetoothStateSubscription = FlutterBluePlus.adapterState.listen(
          (BluetoothAdapterState state) {
        if (state == BluetoothAdapterState.off) {
          _state.setStatusMessage("Bluetooth is turned off");
          onStateChanged(_state);
          _handleBluetoothDisabled();
        }
      },
    );
  }

  void _startAutoScan() {
    _autoScanTimer?.cancel();
    _autoScanTimer = Timer.periodic(autoScanInterval, (_) {
      if (!_state.isScanning && !_state.isConnecting) {
        _updateDeviceList();
      }
    });
  }

  Future<void> _updateDeviceList() async {
    if (!mounted || _state.isScanning || _state.isConnecting) return;

    try {
      final currentSelectedDevice = _state.selectedDevice;
      final devices = await _bleUtils.startScan(
        checkIfPoweredOn: false,
        timeout: const Duration(seconds: 2),
      );

      // Only update the device list if we're still mounted and not connecting
      if (!mounted || _state.isConnecting) return;

      // Preserve the selected device if it still exists in the new list
      BluetoothDevice? updatedSelectedDevice;
      if (currentSelectedDevice != null) {
        updatedSelectedDevice = devices.firstWhere(
              (device) => device.remoteId.str == currentSelectedDevice.remoteId.str,
          orElse: () => currentSelectedDevice,
        );
      }

      _state.setNearbyDevices(devices);
      if (updatedSelectedDevice != null) {
        _state.setSelectedDevice(updatedSelectedDevice);
      }
      _state.setLastScanTime(DateTime.now());
      onStateChanged(_state);
    } catch (e) {
      if (!mounted) return;
      _state.setStatusMessage("Scan update failed: ${e.toString()}");
      onStateChanged(_state);
    }
  }

  Future<void> startScan() async {
    if (!mounted || _state.isScanning) return;

    _state.setScanning(true);
    onStateChanged(_state);

    try {
      await FlutterBluePlus.stopScan();

      // Store current selected device
      final currentSelectedDevice = _state.selectedDevice;

      final devices = await _bleUtils.startScan();
      if (!mounted) return;

      // Preserve selected device if it still exists in the new list
      if (currentSelectedDevice != null) {
        final updatedSelectedDevice = devices.firstWhere(
              (device) => device.remoteId.str == currentSelectedDevice.remoteId.str,
          orElse: () => currentSelectedDevice,
        );
        _state.setSelectedDevice(updatedSelectedDevice);
      }

      _state.setNearbyDevices(devices);
      _state.setLastScanTime(DateTime.now());
      _state.setScanning(false);
      onStateChanged(_state);
    } catch (e) {
      if (!mounted) return;
      _state.setStatusMessage("Scan failed: ${e.toString()}");
      _state.setScanning(false);
      onStateChanged(_state);
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    while (_state.canRetry()) {
      try {
        await bleService.connectToDevice(device);

        // Wait for connection confirmation with timeout
        final completer = Completer<bool>();
        Timer? timeoutTimer;

        timeoutTimer = Timer(connectionTimeout, () {
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        });

        StreamSubscription? subscription;
        subscription = bleService.connectionStatusStream.listen((connected) {
          if (connected && !completer.isCompleted) {
            timeoutTimer?.cancel();
            subscription?.cancel();
            completer.complete(true);
          }
        });

        final connected = await completer.future;

        if (connected) {
          return true;
        }

        _state.incrementRetries();
        if (_state.canRetry()) {
          _state.setStatusMessage(
              "Retrying connection (${_state.connectionRetries + 1}/${AddDeviceState.maxRetries})..."
          );
          onStateChanged(_state);
          await Future.delayed(retryDelay);
        }
      } catch (e) {
        _state.incrementRetries();
        if (_state.canRetry()) {
          _state.setStatusMessage("Connection attempt failed, retrying...");
          onStateChanged(_state);
          await Future.delayed(retryDelay);
        } else {
          throw Exception(
              "Failed to connect after ${_state.connectionRetries} attempts: $e"
          );
        }
      }
    }
    return false;
  }

  void _handleConnectionFailure() async {
    if (_state.canRetry() && _state.selectedDevice != null) {
      _state.incrementRetries();
      _state.setStatusMessage("Connection lost, retrying...");
      onStateChanged(_state);
      await connectToDevice(_state.selectedDevice!);
    }
  }

  bool get mounted => context.mounted;

  void dispose() {
    _deviceStateSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    _bluetoothStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _autoScanTimer?.cancel();
    if (!_state.isCompleted && _state.isConnecting) {
      bleService.disconnectFromDevice();
    }
  }
}