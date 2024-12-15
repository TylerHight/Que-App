// lib/core/services/ble/ble_service.dart

import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../constants/ble_constants.dart';
import 'managers/connection_manager.dart';
import 'managers/characteristics_manager.dart';
import 'managers/keep_alive_manager.dart';
import 'ble_types.dart';

class BleService {
  // Singleton pattern
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;

  late final BleConnectionManager _connectionManager;
  late final BleCharacteristicsManager _characteristicsManager;
  late final BleKeepAliveManager _keepAliveManager;

  // Stream controllers
  final _deviceStateController = StreamController<String>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();

  // State
  BluetoothDevice? _connectedDevice;
  BleConnectionState _connectionState = BleConnectionState.disconnected;

  // Public streams and getters
  Stream<String> get deviceStateStream => _deviceStateController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _connectionState == BleConnectionState.connected;

  BleService._internal() {
    _connectionManager = BleConnectionManager(
      onStateChange: _handleConnectionStateChange,
      onError: _handleConnectionError,
    );

    _characteristicsManager = BleCharacteristicsManager(
      onError: _handleCharacteristicError,
    );

    _keepAliveManager = BleKeepAliveManager(
      interval: const Duration(seconds: 15),
      onKeepAliveFailed: _handleKeepAliveFailed,
    );
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_connectionState == BleConnectionState.connecting) return;

    try {
      _updateState(BleConnectionState.connecting);
      _deviceStateController.add("Connecting to device...");

      await device.connect(timeout: BleConstants.CONNECTION_TIMEOUT);
      _connectedDevice = device;

      // Request MTU
      await device.requestMtu(512);

      // Discover services immediately after connection
      final services = await device.discoverServices();

      // Verify required service and characteristic exist
      final hasRequiredService = services.any(
              (service) => service.uuid.toString().toLowerCase() == BleConstants.LED_SERVICE_UUID.toLowerCase()
      );

      if (!hasRequiredService) {
        throw BleException('Required BLE service not found on device');
      }

      _updateState(BleConnectionState.connected);
      _deviceStateController.add("Connected successfully");
      _connectionStatusController.add(true);

    } catch (e) {
      _handleConnectionError(e);
      rethrow;
    }
  }

  Future<void> _initializeDevice(BluetoothDevice device) async {
    try {
      await _characteristicsManager.discoverCharacteristics(device);

      _keepAliveManager.startKeepAlive(() async {
        await _characteristicsManager.readCharacteristic(
            BleConstants.SWITCH_CHARACTERISTIC_UUID
        );
      });

      _updateState(BleConnectionState.connected);
      _deviceStateController.add("Connected successfully");
      _connectionStatusController.add(true);

    } catch (e) {
      _handleConnectionError(e);
      rethrow;
    }
  }

  void _handleConnectionStateChange(BleConnectionState newState) {
    _updateState(newState);
    _connectionStatusController.add(isConnected);

    if (newState == BleConnectionState.disconnected) {
      _deviceStateController.add("Device disconnected");
      _handleDisconnection();
    }
  }

  void _handleConnectionError(dynamic error) {
    _deviceStateController.add("Connection error: $error");
    _handleDisconnection();
  }

  void _handleCharacteristicError(String message) {
    _deviceStateController.add("Device error: $message");
  }

  void _handleKeepAliveFailed() async {
    _deviceStateController.add("Keep-alive failed, attempting recovery");
    if (_connectedDevice != null) {
      await _connectionManager.attemptRecovery(_connectedDevice!);
    }
  }

  void _updateState(BleConnectionState newState) {
    _connectionState = newState;
  }

  void _handleDisconnection() {
    _updateState(BleConnectionState.disconnected);
    _connectedDevice = null;
    _keepAliveManager.stopKeepAlive();

    // Only add to streams if they're still active
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(false);
    }
  }

  // Device Operations
  Future<void> setLedColor(int colorCommand) async {
    if (_connectedDevice == null) {
      throw BleException('No device connected');
    }

    try {
      // Discover services if not already done
      final services = await _connectedDevice!.discoverServices();

      // Find the LED service
      final ledService = services.firstWhere(
            (service) => service.uuid.toString().toLowerCase() == BleConstants.LED_SERVICE_UUID.toLowerCase(),
        orElse: () => throw BleException('LED service not found'),
      );

      // Find the switch characteristic
      final switchCharacteristic = ledService.characteristics.firstWhere(
            (char) => char.uuid.toString().toLowerCase() == BleConstants.SWITCH_CHARACTERISTIC_UUID.toLowerCase(),
        orElse: () => throw BleException('Switch characteristic not found'),
      );

      // Write the color command
      await switchCharacteristic.write([colorCommand], withoutResponse: false);
      _deviceStateController.add("LED command sent: $colorCommand");
    } catch (e) {
      _deviceStateController.add("Failed to set LED: $e");
      throw BleException('Failed to set LED color: $e');
    }
  }

  Future<void> updateEmission1Duration(String deviceId, Duration duration) async {
    _ensureConnected();

    try {
      await _characteristicsManager.writeCharacteristic(
        BleConstants.SWITCH_CHARACTERISTIC_UUID,
        [BleConstants.CMD_EMISSION1_DURATION, duration.inSeconds],
      );
    } catch (e) {
      throw BleException('Failed to update emission 1 duration: $e');
    }
  }

  Future<void> updateEmission2Duration(String deviceId, Duration duration) async {
    _ensureConnected();

    try {
      await _characteristicsManager.writeCharacteristic(
        BleConstants.SWITCH_CHARACTERISTIC_UUID,
        [BleConstants.CMD_EMISSION2_DURATION, duration.inSeconds],
      );
    } catch (e) {
      throw BleException('Failed to update emission 2 duration: $e');
    }
  }

  Future<void> updateInterval1(String deviceId, Duration interval) async {
    _ensureConnected();

    try {
      await _characteristicsManager.writeCharacteristic(
        BleConstants.SWITCH_CHARACTERISTIC_UUID,
        [BleConstants.CMD_INTERVAL1, interval.inSeconds],
      );
    } catch (e) {
      throw BleException('Failed to update interval 1: $e');
    }
  }

  Future<void> updateInterval2(String deviceId, Duration interval) async {
    _ensureConnected();

    try {
      await _characteristicsManager.writeCharacteristic(
        BleConstants.SWITCH_CHARACTERISTIC_UUID,
        [BleConstants.CMD_INTERVAL2, interval.inSeconds],
      );
    } catch (e) {
      throw BleException('Failed to update interval 2: $e');
    }
  }

  Future<void> updatePeriodicEmission1(String deviceId, bool enabled) async {
    _ensureConnected();

    try {
      await _characteristicsManager.writeCharacteristic(
        BleConstants.SWITCH_CHARACTERISTIC_UUID,
        [BleConstants.CMD_PERIODIC1, enabled ? 1 : 0],
      );
    } catch (e) {
      throw BleException('Failed to update periodic emission 1: $e');
    }
  }

  Future<void> updatePeriodicEmission2(String deviceId, bool enabled) async {
    _ensureConnected();

    try {
      await _characteristicsManager.writeCharacteristic(
        BleConstants.SWITCH_CHARACTERISTIC_UUID,
        [BleConstants.CMD_PERIODIC2, enabled ? 1 : 0],
      );
    } catch (e) {
      throw BleException('Failed to update periodic emission 2: $e');
    }
  }

  Future<void> updateHeartRateThreshold(String deviceId, int threshold) async {
    _ensureConnected();

    try {
      await _characteristicsManager.writeCharacteristic(
        BleConstants.SWITCH_CHARACTERISTIC_UUID,
        [BleConstants.CMD_HEARTRATE, threshold],
      );
    } catch (e) {
      throw BleException('Failed to update heart rate threshold: $e');
    }
  }

  Future<List<BluetoothDevice>> scanForHeartRateMonitors() async {
    if (_connectionState == BleConnectionState.connecting) return [];

    try {
      return await _connectionManager.scanForDevices(
        timeout: const Duration(seconds: 4),
        withServices: [Guid(BleConstants.HEARTRATE_SERVICE_UUID)],
        filter: (device) => device.platformName.toLowerCase().contains("heart"),
      );
    } finally {
      await FlutterBluePlus.stopScan();
    }
  }

  Future<void> disconnectFromDevice() async {
    try {
      if (_connectionState == BleConnectionState.disconnecting) return;

      _updateState(BleConnectionState.disconnecting);
      _keepAliveManager.stopKeepAlive();

      if (_connectedDevice != null) {
        await _connectionManager.disconnect(_connectedDevice!);
      }
    } catch (e) {
      _deviceStateController.addError('Disconnect error: $e');
    } finally {
      _handleDisconnection();
    }
  }

  void _ensureConnected() {
    if (_connectionState != BleConnectionState.connected) {
      throw BleException('Device not connected');
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
    _ensureConnected();

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
        throw BleException('Failed to update ${entry.key}: $e');
      }
    }
  }

  Future<void> startScan() async {
    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
        androidScanMode: AndroidScanMode.lowLatency,
      );
    } catch (e) {
      throw BleException('Failed to start scan: $e');
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      throw BleException('Failed to stop scan: $e');
    }
  }

  void dispose() async {
    try {
      await disconnectFromDevice();
    } catch (_) {
      // Ignore disconnect errors during disposal
    }

    // Close streams
    await _deviceStateController.close();
    await _connectionStatusController.close();
    _connectionManager.dispose();
    _characteristicsManager.dispose();
    _keepAliveManager.dispose();
  }
}

class BleException implements Exception {
  final String message;
  BleException(this.message);

  @override
  String toString() => message;
}