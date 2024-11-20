// lib/utils/ble_utils.dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleUtils {
  static const String TARGET_DEVICE_NAME = "Nano 33 BLE";
  static const Duration SCAN_TIMEOUT = Duration(seconds: 4);

  // Singleton pattern
  static final BleUtils _instance = BleUtils._internal();
  factory BleUtils() => _instance;
  BleUtils._internal();

  Future<List<BluetoothDevice>> startScan({
    Duration timeout = SCAN_TIMEOUT,
    bool checkIfPoweredOn = true,
  }) async {
    try {
      // Check if Bluetooth is available and on
      if (checkIfPoweredOn) {
        if (await FlutterBluePlus.isSupported == false) {
          throw Exception("Bluetooth not supported on this device");
        }

        final isOn = await FlutterBluePlus.isOn;
        if (!isOn) {
          await FlutterBluePlus.turnOn();
        }
      }

      // Clear any existing scan results
      await FlutterBluePlus.stopScan();

      // Start new scan
      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidScanMode: AndroidScanMode.lowLatency,
      );

      // Wait for and filter scan results
      final results = await FlutterBluePlus.scanResults.firstWhere(
            (results) => results.any(
                (result) => result.device.platformName == TARGET_DEVICE_NAME
        ),
        orElse: () => [],
      );

      // Filter and sort devices
      return _processResults(results);

    } catch (e) {
      throw Exception("BLE scan error: $e");
    } finally {
      // Always stop scanning
      await FlutterBluePlus.stopScan();
    }
  }

  List<BluetoothDevice> _processResults(List<ScanResult> results) {
    final devices = <BluetoothDevice>[];
    final seen = <String>{};

    for (var result in results) {
      final device = result.device;
      final deviceId = device.remoteId.toString();

      // Skip if we've already seen this device
      if (seen.contains(deviceId)) continue;
      seen.add(deviceId);

      // Only add devices matching our criteria
      if (_isValidDevice(result)) {
        devices.add(device);
      }
    }

    // Sort by RSSI (signal strength)
    devices.sort((a, b) {
      final aResult = results.firstWhere((r) => r.device.remoteId == a.remoteId);
      final bResult = results.firstWhere((r) => r.device.remoteId == b.remoteId);
      return (bResult.rssi).compareTo(aResult.rssi);
    });

    return devices;
  }

  bool _isValidDevice(ScanResult result) {
    // Check if device is our target device
    return result.device.platformName == TARGET_DEVICE_NAME &&
        result.advertisementData.connectable;
  }

  Future<bool> checkDeviceConnected(BluetoothDevice device) async {
    try {
      final connectedDevices = await FlutterBluePlus.connectedDevices;
      return connectedDevices.any(
              (d) => d.remoteId == device.remoteId
      );
    } catch (e) {
      print("Error checking device connection: $e");
      return false;
    }
  }

  Future<List<BluetoothDevice>> getConnectedDevices() async {
    try {
      final devices = await FlutterBluePlus.connectedDevices;
      return devices.where(
              (device) => device.platformName == TARGET_DEVICE_NAME
      ).toList();
    } catch (e) {
      print("Error getting connected devices: $e");
      return [];
    }
  }

  String getDeviceIdentifier(BluetoothDevice device) {
    return device.remoteId.toString();
  }
}