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
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  Timer? _keepAliveTimer;

  // Stream controllers
  final _deviceStateController = StreamController<String>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();
  final _notificationController = StreamController<List<int>>.broadcast();

  // Public streams and getters
  Stream<String> get deviceStateStream => _deviceStateController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  Stream<List<int>> get notifications => _notificationController.stream;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _isConnected;

  // Connection management
  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      await disconnectFromDevice();
      _deviceStateController.add("Connecting to ${device.platformName}...");

      await device.connect(
        timeout: BleConstants.CONNECTION_TIMEOUT,
        autoConnect: false,
      );
      _connectedDevice = device;

      _setupConnectionMonitoring(device);
      await Future.delayed(const Duration(seconds: 1));

      await _discoverServices();

      _isConnected = true;
      _connectionStatusController.add(true);
      _deviceStateController.add("Connected to ${device.platformName}");
      _startKeepAliveTimer();

    } catch (e) {
      _deviceStateController.add("Connection failed: $e");
      await disconnectFromDevice();
      throw Exception("Failed to connect: $e");
    } finally {
      _isConnecting = false;
    }
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
      // Updated: Use lastValueStream instead of value
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
        await reconnectIfNeeded();
      }
    });
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
      await reconnectIfNeeded();
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

  Future<void> forgetDevice(String deviceId) async {
    if (_connectedDevice?.remoteId.str == deviceId) {
      await disconnectFromDevice();
    }
    _deviceStateController.add("Device forgotten: $deviceId");
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