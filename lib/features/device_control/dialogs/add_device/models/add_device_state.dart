// lib/features/device_control/dialogs/add_device/models/add_device_state.dart

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class AddDeviceState {
  bool _isScanning = false;
  bool _isConnecting = false;
  String _statusMessage = '';
  List<BluetoothDevice> _nearbyDevices = [];
  BluetoothDevice? _selectedDevice;
  int _scanRetries = 0;
  DateTime? _lastScanTime;

  static const int maxRetries = 3;

  // Getters
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  String get statusMessage => _statusMessage;
  List<BluetoothDevice> get nearbyDevices => List.unmodifiable(_nearbyDevices);
  BluetoothDevice? get selectedDevice => _selectedDevice;
  int get scanRetries => _scanRetries;
  DateTime? get lastScanTime => _lastScanTime;

  void setScanning(bool value) {
    _isScanning = value;
    if (value) {
      _nearbyDevices.clear();
    }
  }

  void setConnecting(bool value) {
    _isConnecting = value;
    if (!value) {
      _scanRetries = 0;
    }
  }

  void setStatusMessage(String message) {
    _statusMessage = message;
  }

  void updateDevices(List<BluetoothDevice> devices) {
    _nearbyDevices = devices;
    _statusMessage = devices.isEmpty ? "No devices found" : "";
  }

  void setSelectedDevice(BluetoothDevice? device) {
    _selectedDevice = device;
    _scanRetries = 0;
  }

  void setLastScanTime(DateTime time) {
    _lastScanTime = time;
  }

  void incrementRetries() {
    _scanRetries++;
  }

  bool canRetry() {
    return _scanRetries < maxRetries;
  }

  void reset() {
    _isScanning = false;
    _isConnecting = false;
    _statusMessage = '';
    _nearbyDevices.clear();
    _selectedDevice = null;
    _scanRetries = 0;
    _lastScanTime = null;
  }
}