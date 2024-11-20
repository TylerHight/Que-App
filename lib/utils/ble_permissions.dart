// lib/utils/ble_permissions.dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BlePermissions {
  static Future<bool> requestPermissions() async {
    // Request location permission for Android
    if (!await Permission.location.isGranted) {
      final status = await Permission.location.request();
      if (!status.isGranted) {
        return false;
      }
    }

    // Request Bluetooth permissions for Android 12+
    if (!await Permission.bluetooth.isGranted) {
      final status = await Permission.bluetooth.request();
      if (!status.isGranted) {
        return false;
      }
    }

    if (!await Permission.bluetoothScan.isGranted) {
      final status = await Permission.bluetoothScan.request();
      if (!status.isGranted) {
        return false;
      }
    }

    if (!await Permission.bluetoothConnect.isGranted) {
      final status = await Permission.bluetoothConnect.request();
      if (!status.isGranted) {
        return false;
      }
    }

    return true;
  }

  static Future<bool> checkBleStatus() async {
    try {
      // Check if Bluetooth is turned on
      if (await FlutterBluePlus.isSupported == false) {
        return false;
      }

      // Request to turn on Bluetooth if it's off
      if (await FlutterBluePlus.isOn == false) {
        await FlutterBluePlus.turnOn();
      }

      return true;
    } catch (e) {
      print('Error checking BLE status: $e');
      return false;
    }
  }
}