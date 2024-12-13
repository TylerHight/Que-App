// lib/core/utils/ble/ble_permissions.dart

import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BlePermissions {
  /// Request all necessary BLE permissions based on platform
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final locationStatus = await Permission.locationWhenInUse.request();
      if (!locationStatus.isGranted) {
        return false;
      }

      // For Android 12+ additional permissions are required
      if (await Permission.bluetoothScan.request().isGranted &&
          await Permission.bluetoothConnect.request().isGranted &&
          await Permission.bluetoothAdvertise.request().isGranted) {
        return true;
      }
      return false;
    }
    else if (Platform.isIOS) {
      final bluetoothStatus = await Permission.bluetooth.request();
      return bluetoothStatus.isGranted;
    }

    return false;
  }

  /// Check if Bluetooth is available and enabled
  static Future<bool> checkBleStatus() async {
    try {
      // Check if BLE is supported on the device
      if (await FlutterBluePlus.isSupported == false) {
        throw Exception("Bluetooth not supported on this device");
      }

      // Get current adapter state
      final adapterState = await FlutterBluePlus.adapterState.first;

      if (adapterState != BluetoothAdapterState.on) {
        // Try to turn on Bluetooth
        await FlutterBluePlus.turnOn();

        // Wait for adapter state to change
        final newState = await FlutterBluePlus.adapterState.first;
        return newState == BluetoothAdapterState.on;
      }

      return true;
    } catch (e) {
      print('Error checking BLE status: $e');
      return false;
    }
  }

  /// Monitor Bluetooth state changes
  static Stream<bool> get bluetoothStateStream {
    return FlutterBluePlus.adapterState.map((state) => state == BluetoothAdapterState.on);
  }

  /// Check if all required permissions are granted
  static Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      return await Permission.bluetooth.isGranted &&
          await Permission.bluetoothScan.isGranted &&
          await Permission.bluetoothConnect.isGranted &&
          await Permission.bluetoothAdvertise.isGranted &&
          await Permission.locationWhenInUse.isGranted;
    }
    else if (Platform.isIOS) {
      return await Permission.bluetooth.isGranted;
    }
    return false;
  }
}