/// ble_service.dart

import 'package:flutter_blue/flutter_blue.dart';

class BleService {
  final String serviceUUID = "0000180a-0000-1000-8000-00805f9b34fb";
  final String controlCharacteristicUUID = "00002a57-0000-1000-8000-00805f9b34fb";
  final String settingCharacteristicUUID = "19b10001-e8f2-537e-4f6c-d104768a1214";

  BluetoothCharacteristic? controlCharacteristic;
  BluetoothCharacteristic? settingCharacteristic;

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();

      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        if (service.uuid.toString() == serviceUUID) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == controlCharacteristicUUID) {
              controlCharacteristic = characteristic;
            } else if (characteristic.uuid.toString() == settingCharacteristicUUID) {
              settingCharacteristic = characteristic;
            }
          }
          break;
        }
      }
    } catch (e) {
      throw Exception("Error connecting to device: $e");
    }
  }

  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
    } catch (e) {
      throw Exception("Error disconnecting from device: $e");
    }
  }

  Future<void> sendCommand(int command) async {
    try {
      final characteristic = controlCharacteristic;
      if (characteristic != null) {
        await characteristic.write([command]);
      } else {
        throw Exception("Control characteristic is null");
      }
    } catch (e) {
      throw Exception("Error sending command: $e");
    }
  }

  Future<void> sendSetting(int parameter, int value) async {
    try {
      final characteristic = settingCharacteristic;
      if (characteristic != null) {
        await characteristic.write([parameter, value]);
      } else {
        throw Exception("Setting characteristic is null");
      }
    } catch (e) {
      throw Exception("Error sending setting: $e");
    }
  }
}
