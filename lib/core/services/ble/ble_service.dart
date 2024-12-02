// lib/core/services/ble/ble_service.dart

import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../constants/ble_constants.dart';

class BleService {
  // Singleton pattern
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  // Private state
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _switchCharacteristic;
  bool _isConnecting = false;
  bool _isConnected = false;
  int _retryAttempt = 0;
  Timer? _keepAliveTimer;
  StreamSubscription? _connectionSubscription;

  // Stream controllers
  final _deviceStateController = StreamController<String>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();

  // Configuration
  static const Duration keepAliveInterval = Duration(seconds: 15);
  static const int maxRetryAttempts = 3;

  // Public streams and getters
  Stream<String> get deviceStateStream => _deviceStateController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _isConnected;

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return;
    _isConnecting = true;
    _retryAttempt = 0;

    try {
      await _attemptConnection(device);
    } catch (e) {
      _handleConnectionError(e);
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _attemptConnection(BluetoothDevice device) async {
    await disconnectFromDevice();

    try {
      await device.connect(
          timeout: BleConstants.CONNECTION_TIMEOUT,
          autoConnect: false
      );

      _connectedDevice = device;
      await _setupConnection(device);

    } catch (e) {
      if (_retryAttempt < maxRetryAttempts) {
        _retryAttempt++;
        await Future.delayed(Duration(seconds: _retryAttempt));
        await _attemptConnection(device);
      } else {
        throw Exception('Failed to connect after $_retryAttempt attempts');
      }
    }
  }

  Future<void> _setupConnection(BluetoothDevice device) async {
    await Future.delayed(const Duration(seconds: 1));
    await _discoverServices();
    _setupConnectionMonitoring(device);
    _startKeepAliveTimer();

    _isConnected = true;
    _connectionStatusController.add(true);
    _deviceStateController.add("Connected successfully");
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
        }
    );
  }

  void _startKeepAliveTimer() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(keepAliveInterval, (_) async {
      if (_isConnected && _switchCharacteristic != null) {
        try {
          await _switchCharacteristic!.read();
          _deviceStateController.add("Keep-alive successful");
        } catch (e) {
          _deviceStateController.add("Keep-alive failed: $e");
          await _handleConnectionFailure();
        }
      }
    });
  }

  Future<void> _discoverServices() async {
    final services = await _connectedDevice!.discoverServices();

    final ledService = services.firstWhere(
            (service) => service.uuid.toString().toLowerCase() ==
            BleConstants.LED_SERVICE_UUID.toLowerCase(),
        orElse: () => throw Exception("LED service not found")
    );

    _switchCharacteristic = ledService.characteristics.firstWhere(
            (char) => char.uuid.toString().toLowerCase() ==
            BleConstants.SWITCH_CHARACTERISTIC_UUID.toLowerCase(),
        orElse: () => throw Exception("Switch characteristic not found")
    );
  }

  Future<void> _handleConnectionFailure() async {
    if (_connectedDevice != null && _retryAttempt < maxRetryAttempts) {
      _deviceStateController.add("Connection unstable, attempting recovery");
      await _attemptConnection(_connectedDevice!);
    }
  }

  void _handleConnectionError(dynamic error) {
    _deviceStateController.add("Connection error: $error");
    _handleDisconnection();
  }

  void _handleDisconnection() {
    _isConnected = false;
    _connectedDevice = null;
    _switchCharacteristic = null;
    _keepAliveTimer?.cancel();
    _connectionSubscription?.cancel();
    _connectionStatusController.add(false);
  }

  Future<void> setLedColor(int colorCommand) async {
    if (!_isConnected || _switchCharacteristic == null) {
      throw Exception('Device not connected');
    }

    try {
      await _switchCharacteristic!.write([colorCommand]);
      _deviceStateController.add("LED command sent: $colorCommand");
    } catch (e) {
      _deviceStateController.add("Failed to set LED: $e");
      throw Exception("Failed to set LED: $e");
    }
  }

  Future<void> disconnectFromDevice() async {
    _keepAliveTimer?.cancel();
    _connectionSubscription?.cancel();

    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
    } catch (e) {
      _deviceStateController.add("Disconnect error: $e");
    } finally {
      _handleDisconnection();
    }
  }

  void dispose() {
    disconnectFromDevice();
    _deviceStateController.close();
    _connectionStatusController.close();
  }

  Future<void> updateEmission1Duration(String deviceId, Duration duration) async {
    if (!_isConnected || _switchCharacteristic == null) {
      throw Exception('Device not connected');
    }
    try {
      // Convert duration to bytes and send
      final bytes = [BleConstants.CMD_EMISSION1_DURATION, duration.inSeconds];
      await _switchCharacteristic!.write(bytes);
    } catch (e) {
      throw Exception('Failed to update emission 1 duration: $e');
    }
  }

  Future<void> updateEmission2Duration(String deviceId, Duration duration) async {
    if (!_isConnected || _switchCharacteristic == null) {
      throw Exception('Device not connected');
    }
    try {
      final bytes = [BleConstants.CMD_EMISSION2_DURATION, duration.inSeconds];
      await _switchCharacteristic!.write(bytes);
    } catch (e) {
      throw Exception('Failed to update emission 2 duration: $e');
    }
  }

  Future<void> updateInterval1(String deviceId, Duration interval) async {
    if (!_isConnected || _switchCharacteristic == null) {
      throw Exception('Device not connected');
    }
    try {
      final bytes = [BleConstants.CMD_INTERVAL1, interval.inSeconds];
      await _switchCharacteristic!.write(bytes);
    } catch (e) {
      throw Exception('Failed to update interval 1: $e');
    }
  }

  Future<void> updateInterval2(String deviceId, Duration interval) async {
    if (!_isConnected || _switchCharacteristic == null) {
      throw Exception('Device not connected');
    }
    try {
      final bytes = [BleConstants.CMD_INTERVAL2, interval.inSeconds];
      await _switchCharacteristic!.write(bytes);
    } catch (e) {
      throw Exception('Failed to update interval 2: $e');
    }
  }

  Future<void> updatePeriodicEmission1(String deviceId, bool enabled) async {
    if (!_isConnected || _switchCharacteristic == null) {
      throw Exception('Device not connected');
    }
    try {
      final bytes = [BleConstants.CMD_PERIODIC1, enabled ? 1 : 0];
      await _switchCharacteristic!.write(bytes);
    } catch (e) {
      throw Exception('Failed to update periodic emission 1: $e');
    }
  }

  Future<void> updatePeriodicEmission2(String deviceId, bool enabled) async {
    if (!_isConnected || _switchCharacteristic == null) {
      throw Exception('Device not connected');
    }
    try {
      final bytes = [BleConstants.CMD_PERIODIC2, enabled ? 1 : 0];
      await _switchCharacteristic!.write(bytes);
    } catch (e) {
      throw Exception('Failed to update periodic emission 2: $e');
    }
  }

  Future<void> updateHeartRateThreshold(String deviceId, int threshold) async {
    if (!_isConnected || _switchCharacteristic == null) {
      throw Exception('Device not connected');
    }
    try {
      final bytes = [BleConstants.CMD_HEARTRATE, threshold];
      await _switchCharacteristic!.write(bytes);
    } catch (e) {
      throw Exception('Failed to update heart rate threshold: $e');
    }
  }

  Future<List<BluetoothDevice>> scanForHeartRateMonitors() async {
    if (_isConnecting) return [];

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
        withServices: [Guid(BleConstants.HEARTRATE_SERVICE_UUID)],
      );

      final results = await FlutterBluePlus.scanResults.first;
      return results
          .where((r) => r.device.platformName.toLowerCase().contains("heart"))
          .map((r) => r.device)
          .toList();
    } finally {
      await FlutterBluePlus.stopScan();
    }
  }

  Future<void> connectToHeartRateMonitor(String deviceId, BluetoothDevice monitor) async {
    try {
      await monitor.connect(timeout: BleConstants.CONNECTION_TIMEOUT);
      _deviceStateController.add("Connected to heart rate monitor");
    } catch (e) {
      throw Exception('Failed to connect to heart rate monitor: $e');
    }
  }

  Future<void> forgetDevice(String deviceId) async {
    await disconnectFromDevice();
    _deviceStateController.add("Device forgotten: $deviceId");
  }

  Future<void> updateDeviceSettings(String deviceId, Map<String, dynamic> settings) async {
    if (!_isConnected || _switchCharacteristic == null) {
      throw Exception('Device not connected');
    }

    for (final entry in settings.entries) {
      try {
        switch (entry.key) {
          case 'emission1Duration':
            await updateEmission1Duration(deviceId, entry.value as Duration);
            break;
          case 'emission2Duration':
            await updateEmission2Duration(deviceId, entry.value as Duration);
            break;
        // Add cases for other settings...
        }
      } catch (e) {
        throw Exception('Failed to update ${entry.key}: $e');
      }
    }
  }
}