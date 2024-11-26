// lib/services/ble_service.dart

import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  // Arduino's UUIDs and commands
  static const String DEVICE_NAME = "Nano 33 BLE";
  static const String LED_SERVICE_UUID = "180a";
  static const String SWITCH_CHAR_UUID = "2a57";

  // LED control commands
  static const int LED_OFF = 0;
  static const int LED_RED = 1;
  static const int LED_GREEN = 2;
  static const int LED_BLUE = 3;

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _switchCharacteristic;
  bool _isConnecting = false;
  bool _isConnected = false;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  Timer? _keepAliveTimer;

  final _deviceStateController = StreamController<String>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();
  final _notificationController = StreamController<List<int>>.broadcast();

  Stream<String> get deviceStateStream => _deviceStateController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  Stream<List<int>> get notifications => _notificationController.stream;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // Added isConnected getter
  bool get isConnected => _isConnected;

  String _getShortUUID(String fullUUID) {
    try {
      return fullUUID.replaceAll('-', '').replaceAll('0000', '').substring(0, 4).toLowerCase();
    } catch (e) {
      return fullUUID.toLowerCase();
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      // Disconnect from any existing device first
      await disconnectFromDevice();

      _deviceStateController.add("Connecting to ${device.platformName}...");

      // Connect to device
      await device.connect(
        timeout: const Duration(seconds: 10),
        autoConnect: false,
      );
      _connectedDevice = device;

      // Setup connection monitoring
      _setupConnectionMonitoring(device);

      // Wait for connection to stabilize
      await Future.delayed(const Duration(seconds: 1));

      // Discover services
      _deviceStateController.add("Discovering services...");
      final services = await device.discoverServices();

      // Find LED service
      BluetoothService? ledService;
      for (var service in services) {
        String shortUuid = _getShortUUID(service.uuid.toString());
        _deviceStateController.add("Found service: $shortUuid");

        if (shortUuid == LED_SERVICE_UUID) {
          ledService = service;
          break;
        }
      }

      if (ledService == null) {
        throw Exception("LED service not found");
      }

      // Find switch characteristic
      for (var char in ledService.characteristics) {
        String shortUuid = _getShortUUID(char.uuid.toString());
        if (shortUuid == SWITCH_CHAR_UUID) {
          _switchCharacteristic = char;

          // Set up notifications if supported
          if (char.properties.notify) {
            await char.setNotifyValue(true);
            char.value.listen((value) {
              _notificationController.add(value);
            });
          }
          break;
        }
      }

      if (_switchCharacteristic == null) {
        throw Exception("Switch characteristic not found");
      }

      // Mark as connected
      _isConnected = true;
      _connectionStatusController.add(true);
      _deviceStateController.add("Connected to ${device.platformName}");

      // Start keep-alive
      _startKeepAliveTimer();

    } catch (e) {
      _deviceStateController.add("Connection failed: $e");
      await disconnectFromDevice();
      throw Exception("Failed to connect: $e");
    } finally {
      _isConnecting = false;
    }
  }

  void _setupConnectionMonitoring(BluetoothDevice device) {
    _connectionSubscription?.cancel();
    _connectionSubscription = device.connectionState.listen(
            (BluetoothConnectionState state) {
          final isConnected = state == BluetoothConnectionState.connected;
          _isConnected = isConnected;
          _connectionStatusController.add(isConnected);

          if (!isConnected) {
            _deviceStateController.add("Device disconnected");
            _handleDisconnection();
          }
        },
        onError: (error) {
          _deviceStateController.add("Connection error: $error");
          _handleDisconnection();
        }
    );
  }

  void _startKeepAliveTimer() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (!_isConnected) return;
      try {
        if (_switchCharacteristic != null) {
          await _switchCharacteristic!.read();
          _deviceStateController.add("Keep-alive successful");
        }
      } catch (e) {
        _deviceStateController.add("Keep-alive failed: $e");
        await reconnectIfNeeded();
      }
    });
  }

  Future<void> reconnectIfNeeded() async {
    if (!_isConnected && _connectedDevice != null) {
      try {
        _deviceStateController.add("Attempting to reconnect...");
        await connectToDevice(_connectedDevice!);
      } catch (e) {
        _deviceStateController.add("Reconnection failed: $e");
      }
    }
  }

  Future<void> setLedColor(int colorCommand) async {
    if (!_isConnected) {
      throw Exception("Device not connected");
    }

    try {
      if (_switchCharacteristic == null) {
        throw Exception("Device not properly initialized");
      }

      if (colorCommand < LED_OFF || colorCommand > LED_BLUE) {
        throw Exception("Invalid LED command: $colorCommand");
      }

      await _switchCharacteristic!.write([colorCommand], withoutResponse: true);
      _deviceStateController.add("LED command sent: $colorCommand");

    } catch (e) {
      _deviceStateController.add("Failed to set LED: $e");
      await reconnectIfNeeded();
      throw Exception("Failed to set LED: $e");
    }
  }

  Future<void> disconnectFromDevice() async {
    _keepAliveTimer?.cancel();
    _connectionSubscription?.cancel();

    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        _deviceStateController.add("Disconnected from device");
      }
    } catch (e) {
      _deviceStateController.add("Disconnect error: $e");
    } finally {
      _handleDisconnection();
    }
  }

  void _handleDisconnection() {
    _isConnected = false;
    _connectedDevice = null;
    _switchCharacteristic = null;
    _keepAliveTimer?.cancel();
    _connectionSubscription?.cancel();
    _connectionStatusController.add(false);
  }

  void dispose() {
    disconnectFromDevice();
    _keepAliveTimer?.cancel();
    _connectionSubscription?.cancel();
    _deviceStateController.close();
    _connectionStatusController.close();
    _notificationController.close();
  }
}