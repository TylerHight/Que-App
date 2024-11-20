// lib/services/ble_service.dart
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  // Arduino's UUIDs - these match the Arduino sketch
  static const String LED_SERVICE_UUID = "0000180a-0000-1000-8000-00805f9b34fb";
  static const String SWITCH_CHARACTERISTIC_UUID = "00002a57-0000-1000-8000-00805f9b34fb";

  // LED commands matching Arduino implementation
  static const int LED_OFF = 0;
  static const int LED_RED = 1;
  static const int LED_GREEN = 2;
  static const int LED_BLUE = 3;

  // Connection timeout matching Arduino (20 seconds)
  static const Duration CONNECTION_TIMEOUT = Duration(seconds: 20);
  static const Duration SCAN_TIMEOUT = Duration(seconds: 4);

  BluetoothCharacteristic? _switchCharacteristic;
  BluetoothDevice? _connectedDevice;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  Timer? _disconnectTimer;
  bool _isReconnecting = false;

  // Stream controllers
  final _connectionStatusController = StreamController<bool>.broadcast();
  final _deviceStateController = StreamController<String>.broadcast();

  // Public streams
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  Stream<String> get deviceStateStream => _deviceStateController.stream;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  Future<List<ScanResult>> scanForDevices() async {
    try {
      // Check Bluetooth status
      if (await FlutterBluePlus.isSupported == false) {
        throw Exception("Bluetooth not supported on this device");
      }

      if (!await FlutterBluePlus.isOn) {
        await FlutterBluePlus.turnOn();
      }

      await FlutterBluePlus.stopScan();

      await FlutterBluePlus.startScan(
        timeout: SCAN_TIMEOUT,
        androidScanMode: AndroidScanMode.lowLatency,
      );

      final results = await FlutterBluePlus.scanResults.first;
      return results.where((result) =>
      result.device.platformName == "Nano 33 BLE" &&
          result.advertisementData.connectable
      ).toList();
    } catch (e) {
      _deviceStateController.add("Scan failed: ${e.toString()}");
      throw Exception("Scan failed: $e");
    } finally {
      await FlutterBluePlus.stopScan();
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_isReconnecting) return;

    try {
      _isReconnecting = true;
      _deviceStateController.add("Connecting to ${device.platformName}...");

      // Disconnect from any existing connection
      await disconnectFromDevice();

      // Connect to device
      await device.connect(
          timeout: SCAN_TIMEOUT,
          autoConnect: false
      );

      _connectedDevice = device;
      _deviceStateController.add("Connected to ${device.platformName}");

      // Discover services
      await _discoverServices(device);

      // Setup connection monitoring
      _setupConnectionMonitoring(device);

      // Start disconnect timer
      _startDisconnectTimer();

      _connectionStatusController.add(true);
    } catch (e) {
      _deviceStateController.add("Connection failed: ${e.toString()}");
      throw Exception("Failed to connect: $e");
    } finally {
      _isReconnecting = false;
    }
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    try {
      _deviceStateController.add("Discovering services...");

      final services = await device.discoverServices();
      bool foundService = false;

      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == LED_SERVICE_UUID.toLowerCase()) {
          foundService = true;
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() ==
                SWITCH_CHARACTERISTIC_UUID.toLowerCase()) {
              _switchCharacteristic = characteristic;
              _deviceStateController.add("Found LED control service");
              return;
            }
          }
        }
      }

      if (!foundService) {
        throw Exception("LED service not found");
      } else {
        throw Exception("LED characteristic not found");
      }
    } catch (e) {
      _deviceStateController.add("Service discovery failed: ${e.toString()}");
      throw Exception("Service discovery failed: $e");
    }
  }

  void _setupConnectionMonitoring(BluetoothDevice device) {
    _connectionSubscription?.cancel();
    _connectionSubscription = device.connectionState.listen(
            (BluetoothConnectionState state) {
          final isConnected = state == BluetoothConnectionState.connected;
          _connectionStatusController.add(isConnected);

          if (!isConnected) {
            _deviceStateController.add("Device disconnected");
            _cleanupConnection();
          }
        },
        onError: (error) {
          _deviceStateController.add("Connection error: $error");
          _cleanupConnection();
        }
    );
  }

  void _startDisconnectTimer() {
    _disconnectTimer?.cancel();
    _disconnectTimer = Timer.periodic(
        CONNECTION_TIMEOUT,
            (_) => _checkConnectionTimeout()
    );
  }

  Future<void> _checkConnectionTimeout() async {
    if (_connectedDevice != null) {
      final connectionState = await _connectedDevice!.connectionState.first;
      if (connectionState != BluetoothConnectionState.connected) {
        _deviceStateController.add("Connection timed out");
        await disconnectFromDevice();
      }
    }
  }

  Future<void> setLedColor(int colorCommand) async {
    try {
      if (_connectedDevice == null || _switchCharacteristic == null) {
        throw Exception("Device not properly connected");
      }

      if (colorCommand < LED_OFF || colorCommand > LED_BLUE) {
        throw Exception("Invalid LED command: $colorCommand");
      }

      await _switchCharacteristic!.write([colorCommand], withoutResponse: false);
      _deviceStateController.add("LED command sent: $colorCommand");
      _startDisconnectTimer(); // Reset timeout
    } catch (e) {
      _deviceStateController.add("Failed to set LED: ${e.toString()}");
      throw Exception("Failed to set LED: $e");
    }
  }

  Future<void> disconnectFromDevice() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        _deviceStateController.add("Disconnected by request");
      }
    } catch (e) {
      _deviceStateController.add("Disconnect failed: ${e.toString()}");
    } finally {
      _cleanupConnection();
    }
  }

  void _cleanupConnection() {
    _connectedDevice = null;
    _switchCharacteristic = null;
    _disconnectTimer?.cancel();
    _connectionStatusController.add(false);
  }

  Future<bool> isConnected() async {
    if (_connectedDevice == null) return false;

    try {
      final state = await _connectedDevice!.connectionState.first;
      return state == BluetoothConnectionState.connected;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    disconnectFromDevice();
    _connectionSubscription?.cancel();
    _disconnectTimer?.cancel();
    _connectionStatusController.close();
    _deviceStateController.close();
  }
}