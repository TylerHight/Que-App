// lib/core/services/ble_service.dart

import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../constants/ble_constants.dart';

/// BLE Service handles all Bluetooth Low Energy operations
/// Implements connection management, LED control, device settings,
/// and heart rate monitoring functionality.
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
  Timer? _connectionQualityTimer;
  StreamSubscription? _connectionSubscription;

  // Stream controllers
  final _deviceStateController = StreamController<String>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();
  final _connectionQualityController = StreamController<double>.broadcast();
  final _notificationController = StreamController<List<int>>.broadcast();

  // Connection configuration
  static const int maxRetryAttempts = 5;
  static const Duration initialRetryDelay = Duration(seconds: 1);
  static const Duration maxRetryDelay = Duration(seconds: 32);
  static const Duration qualityCheckInterval = Duration(seconds: 5);
  static const int minAcceptableRSSI = -80;

  // Public streams and getters
  Stream<String> get deviceStateStream => _deviceStateController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  Stream<double> get connectionQualityStream => _connectionQualityController.stream;
  Stream<List<int>> get notifications => _notificationController.stream;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _isConnected;

  // Connection management
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
    while (_retryAttempt < maxRetryAttempts) {
      try {
        await disconnectFromDevice();
        _deviceStateController.add("Attempting connection (${_retryAttempt + 1}/$maxRetryAttempts)");

        // Calculate exponential backoff delay
        if (_retryAttempt > 0) {
          final backoffDelay = Duration(
              seconds: (initialRetryDelay.inSeconds * (1 << (_retryAttempt - 1)))
                  .clamp(0, maxRetryDelay.inSeconds)
          );
          await Future.delayed(backoffDelay);
        }

        await device.connect(
            timeout: BleConstants.CONNECTION_TIMEOUT,
            autoConnect: false
        );

        _connectedDevice = device;
        await _setupConnection(device);
        return;

      } catch (e) {
        _retryAttempt++;
        if (_retryAttempt >= maxRetryAttempts) {
          throw Exception('Failed to connect after $_retryAttempt attempts: $e');
        }
      }
    }
  }

  Future<void> _setupConnection(BluetoothDevice device) async {
    await Future.delayed(const Duration(seconds: 1));
    await _discoverServices();

    _setupConnectionMonitoring(device);
    _startKeepAliveTimer();
    _startQualityMonitoring();

    _isConnected = true;
    _connectionStatusController.add(true);
    _deviceStateController.add("Connected successfully");
  }

  Future<void> _discoverServices() async {
    _deviceStateController.add("Discovering services...");
    final services = await _connectedDevice!.discoverServices();

    // Find LED service
    final ledService = services.firstWhere(
          (service) => BleConstants.getShortUUID(service.uuid.toString()) ==
          BleConstants.getShortUUID(BleConstants.LED_SERVICE_UUID),
      orElse: () => throw Exception("LED service not found"),
    );

    // Find switch characteristic
    _switchCharacteristic = ledService.characteristics.firstWhere(
          (char) => BleConstants.getShortUUID(char.uuid.toString()) ==
          BleConstants.getShortUUID(BleConstants.SWITCH_CHARACTERISTIC_UUID),
      orElse: () => throw Exception("Switch characteristic not found"),
    );

    if (_switchCharacteristic!.properties.notify) {
      await _switchCharacteristic!.setNotifyValue(true);
      _switchCharacteristic!.lastValueStream.listen(_notificationController.add);
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
    _keepAliveTimer = Timer.periodic(BleConstants.KEEP_ALIVE_INTERVAL, (_) async {
      if (!_isConnected) return;
      try {
        if (_switchCharacteristic != null) {
          await _switchCharacteristic!.read();
          _deviceStateController.add("Keep-alive successful");
        }
      } catch (e) {
        _deviceStateController.add("Keep-alive failed: $e");
        await _handleConnectionFailure();
      }
    });
  }

  void _startQualityMonitoring() {
    _connectionQualityTimer?.cancel();
    _connectionQualityTimer = Timer.periodic(
        qualityCheckInterval,
            (_) => _checkConnectionQuality()
    );
  }

  Future<void> _checkConnectionQuality() async {
    if (!_isConnected || _connectedDevice == null) return;

    try {
      final rssi = await _connectedDevice!.readRssi();

      // Calculate quality percentage (0-100)
      final quality = ((rssi - minAcceptableRSSI) / (0 - minAcceptableRSSI) * 100)
          .clamp(0.0, 100.0);

      _connectionQualityController.add(quality);

      if (rssi < minAcceptableRSSI) {
        _deviceStateController.add("Poor connection quality");
        await _handleConnectionFailure();
      }
    } catch (e) {
      _deviceStateController.add("Quality check failed: $e");
    }
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
    _connectionQualityTimer?.cancel();
    _connectionSubscription?.cancel();
    _connectionStatusController.add(false);
  }

  // LED control
  Future<void> setLedColor(int colorCommand) async {
    if (!_isConnected) throw Exception("Device not connected");
    if (_switchCharacteristic == null) throw Exception("Device not properly initialized");
    if (!BleConstants.isValidLedCommand(colorCommand)) {
      throw Exception("Invalid LED command: $colorCommand");
    }

    try {
      await _switchCharacteristic!.write([colorCommand], withoutResponse: true);
      _deviceStateController.add("LED command sent: $colorCommand");
    } catch (e) {
      _deviceStateController.add("Failed to set LED: $e");
      await _handleConnectionFailure();
      throw Exception("Failed to set LED: $e");
    }
  }

  // Device settings methods
  Future<void> updateDeviceSettings(String deviceId, Map<String, dynamic> settings) async {
    _requireConnected();

    try {
      final services = await _connectedDevice!.discoverServices();
      final settingsService = services.firstWhere(
              (service) => BleConstants.getShortUUID(service.uuid.toString()) ==
              BleConstants.getShortUUID(BleConstants.SETTINGS_SERVICE_UUID)
      );

      for (var setting in settings.entries) {
        final characteristic = _findCharacteristicForSetting(settingsService, setting.key);
        if (characteristic != null) {
          await characteristic.write([setting.value], withoutResponse: true);
        }
      }
    } catch (e) {
      throw Exception("Failed to update device settings: $e");
    }
  }

  Future<void> updateEmission1Duration(String deviceId, Duration duration) =>
      _writeSettingValue(BleConstants.EMISSION1_CHARACTERISTIC_UUID, duration.inSeconds);

  Future<void> updateEmission2Duration(String deviceId, Duration duration) =>
      _writeSettingValue(BleConstants.EMISSION2_CHARACTERISTIC_UUID, duration.inSeconds);

  Future<void> updateInterval1(String deviceId, Duration interval) =>
      _writeSettingValue(BleConstants.INTERVAL1_CHARACTERISTIC_UUID, interval.inSeconds);

  Future<void> updateInterval2(String deviceId, Duration interval) =>
      _writeSettingValue(BleConstants.INTERVAL2_CHARACTERISTIC_UUID, interval.inSeconds);

  Future<void> updatePeriodicEmission1(String deviceId, bool enabled) =>
      _writeSettingValue(BleConstants.PERIODIC1_CHARACTERISTIC_UUID, enabled ? 1 : 0);

  Future<void> updatePeriodicEmission2(String deviceId, bool enabled) =>
      _writeSettingValue(BleConstants.PERIODIC2_CHARACTERISTIC_UUID, enabled ? 1 : 0);

  Future<void> updateHeartRateThreshold(String deviceId, int threshold) =>
      _writeSettingValue(BleConstants.HEARTRATE_CHARACTERISTIC_UUID, threshold);

  // Heart rate monitoring
  Future<List<BluetoothDevice>> scanForHeartRateMonitors() async {
    if (_isConnecting) return [];

    final List<BluetoothDevice> devices = [];

    // Stop any ongoing scan
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    try {
      // Set up scan subscription
      final subscription = FlutterBluePlus.scanResults.listen((results) {
        devices.addAll(
            results
                .where((r) => r.device.platformName.toLowerCase().contains("heart"))
                .map((r) => r.device)
        );
      });

      // Start scan
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
        withServices: [Guid(BleConstants.HEARTRATE_CHARACTERISTIC_UUID)],
      );

      // Wait for scan to complete
      await Future.delayed(const Duration(seconds: 4));
      await FlutterBluePlus.stopScan();
      await subscription.cancel();

      return devices;
    } catch (e) {
      _deviceStateController.add("Scan failed: $e");
      throw Exception('Failed to scan for heart rate monitors: $e');
    }
  }

  Future<void> connectToHeartRateMonitor(String deviceId, BluetoothDevice monitor) async {
    try {
      await monitor.connect();
      _deviceStateController.add("Connected to heart rate monitor");
    } catch (e) {
      _deviceStateController.add("Failed to connect to heart rate monitor: $e");
      throw Exception("Failed to connect to heart rate monitor: $e");
    }
  }

  // Helper methods
  void _requireConnected() {
    if (!_isConnected || _connectedDevice == null) {
      throw Exception("Device not connected");
    }
  }

  Future<void> _writeSettingValue(String characteristicUuid, dynamic value) async {
    _requireConnected();

    try {
      final services = await _connectedDevice!.discoverServices();
      final settingsService = services.firstWhere(
              (service) => BleConstants.getShortUUID(service.uuid.toString()) ==
              BleConstants.getShortUUID(BleConstants.SETTINGS_SERVICE_UUID)
      );

      final characteristic = settingsService.characteristics.firstWhere(
              (char) => BleConstants.getShortUUID(char.uuid.toString()) ==
              BleConstants.getShortUUID(characteristicUuid)
      );

      List<int> bytes;
      if (value is int) {
        bytes = [value];
      } else if (value is bool) {
        bytes = [value ? 1 : 0];
      } else {
        throw Exception("Unsupported value type");
      }

      await characteristic.write(bytes, withoutResponse: true);
    } catch (e) {
      throw Exception("Failed to write setting value: $e");
    }
  }

  BluetoothCharacteristic? _findCharacteristicForSetting(
      BluetoothService service,
      String settingKey,
      ) {
    final characteristicMap = {
      'emission1': BleConstants.EMISSION1_CHARACTERISTIC_UUID,
      'emission2': BleConstants.EMISSION2_CHARACTERISTIC_UUID,
      'interval1': BleConstants.INTERVAL1_CHARACTERISTIC_UUID,
      'interval2': BleConstants.INTERVAL2_CHARACTERISTIC_UUID,
      'periodic1': BleConstants.PERIODIC1_CHARACTERISTIC_UUID,
      'periodic2': BleConstants.PERIODIC2_CHARACTERISTIC_UUID,
      'heartrate': BleConstants.HEARTRATE_CHARACTERISTIC_UUID,
    };

    final charUuid = characteristicMap[settingKey];
    if (charUuid == null) return null;

    return service.characteristics.firstWhere(
          (char) => BleConstants.getShortUUID(char.uuid.toString()) ==
          BleConstants.getShortUUID(charUuid),
      orElse: () => throw Exception("Characteristic not found for setting: $settingKey"),
    );
  }

  // Reconnection handling
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

  Future<void> disconnectFromDevice() async {
    _keepAliveTimer?.cancel();
    _connectionQualityTimer?.cancel();
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

  Future<void> forgetDevice(String deviceId) async {
    if (_connectedDevice?.remoteId.str == deviceId) {
      await disconnectFromDevice();
    }
    _deviceStateController.add("Device forgotten: $deviceId");
  }

  void dispose() {
    disconnectFromDevice();
    _keepAliveTimer?.cancel();
    _connectionQualityTimer?.cancel();
    _connectionSubscription?.cancel();
    _deviceStateController.close();
    _connectionStatusController.close();
    _connectionQualityController.close();
    _notificationController.close();
  }
}