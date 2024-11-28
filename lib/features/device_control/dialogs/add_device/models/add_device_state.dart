// lib/features/device_control/dialogs/add_device/models/add_device_state.dart

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class AddDeviceState {
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isCompleted = false;
  String _statusMessage = '';
  List<BluetoothDevice> _nearbyDevices = [];
  BluetoothDevice? _selectedDevice;
  int _connectionRetries = 0;

  static const int maxRetries = 3;

  // Getters
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  bool get isCompleted => _isCompleted;
  String get statusMessage => _statusMessage;
  List<BluetoothDevice> get nearbyDevices => List.unmodifiable(_nearbyDevices);
  BluetoothDevice? get selectedDevice => _selectedDevice;
  int get connectionRetries => _connectionRetries;

  // State update methods
  void setScanning(bool value) {
    _isScanning = value;
    if (value) {
      _nearbyDevices.clear();
      _selectedDevice = null;
    }
  }

  void setConnecting(bool value) {
    _isConnecting = value;
    if (!value) {
      _connectionRetries = 0;
    }
  }

  void setCompleted(bool value) {
    _isCompleted = value;
  }

  void setStatusMessage(String message) {
    _statusMessage = message;
  }

  void setNearbyDevices(List<BluetoothDevice> devices) {
    _nearbyDevices = devices;
    _statusMessage = devices.isEmpty ? "No devices found" : "";
  }

  void setSelectedDevice(BluetoothDevice? device) {
    _selectedDevice = device;
    _connectionRetries = 0;
  }

  void incrementRetries() {
    _connectionRetries++;
  }

  bool canRetry() {
    return _connectionRetries < maxRetries;
  }

  // Update multiple properties at once
  void update(AddDeviceState other) {
    _isScanning = other._isScanning;
    _isConnecting = other._isConnecting;
    _isCompleted = other._isCompleted;
    _statusMessage = other._statusMessage;
    _nearbyDevices = other._nearbyDevices;
    _selectedDevice = other._selectedDevice;
    _connectionRetries = other._connectionRetries;
  }

  // Create a copy with updated values
  AddDeviceState copyWith({
    bool? isScanning,
    bool? isConnecting,
    bool? isCompleted,
    String? statusMessage,
    List<BluetoothDevice>? nearbyDevices,
    BluetoothDevice? selectedDevice,
    int? connectionRetries,
  }) {
    final newState = AddDeviceState()
      .._isScanning = isScanning ?? _isScanning
      .._isConnecting = isConnecting ?? _isConnecting
      .._isCompleted = isCompleted ?? _isCompleted
      .._statusMessage = statusMessage ?? _statusMessage
      .._nearbyDevices = nearbyDevices ?? _nearbyDevices
      .._selectedDevice = selectedDevice ?? _selectedDevice
      .._connectionRetries = connectionRetries ?? _connectionRetries;

    return newState;
  }

  // Reset state
  void reset() {
    _isScanning = false;
    _isConnecting = false;
    _isCompleted = false;
    _statusMessage = '';
    _nearbyDevices.clear();
    _selectedDevice = null;
    _connectionRetries = 0;
  }
}