import 'package:flutter_blue/flutter_blue.dart';

class BleService {
  final String serviceUUID = "0000180a-0000-1000-8000-00805f9b34fb";
  final String controlCharacteristicUUID = "00002a57-0000-1000-8000-00805f9b34fb";
  final String settingCharacteristicUUID = "19b10001-e8f2-537e-4f6c-d104768a1214";

  BluetoothCharacteristic? controlCharacteristic;
  BluetoothCharacteristic? settingCharacteristic;
  BluetoothDevice? _connectedDevice;

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      print('Connecting to device: ${device.name}');
      await device.connect();
      _connectedDevice = device;
      await discoverServicesAndCharacteristics(device);
    } catch (e) {
      // Consider adding logging here
      throw Exception("Error connecting to device: $e");
    }
  }

  Future<void> discoverServicesAndCharacteristics(BluetoothDevice device) async {
    print("Discovering services...");
    List<BluetoothService> services = await device.discoverServices();
    print("Available services on ${device.name}:");
    for (var service in services) {
      print("- Service UUID: ${service.uuid}");
      if (service.uuid.toString() == serviceUUID) {
        print("Target service found.");
        print("Searching for matching characteristic(s) in service...");
        for (var characteristic in service.characteristics) {
          print("Found characteristic UUIDs: $characteristic.uuid");
          if (characteristic.uuid.toString() == controlCharacteristicUUID) {
            print("Control characteristic found: ${characteristic.uuid}");
            controlCharacteristic = characteristic;
          } else if (characteristic.uuid.toString() == settingCharacteristicUUID) {
            print("Setting characteristic found: ${characteristic.uuid}");
            settingCharacteristic = characteristic;
          }
          else {
            print("UUIDs did not match");
          }
        }
        break;
      }
    }
  }

  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      _connectedDevice = null;
    } catch (e) {
      // Consider adding logging here
      throw Exception("Error disconnecting from device: $e");
    }
  }

  Future<void> sendCommand(BluetoothCharacteristic? characteristic, int command) async {
    try {
      if (characteristic != null) {
        await characteristic.write([command]);
      } else {
        throw Exception("Characteristic is null");
      }
    } catch (e) {
      // Consider adding logging here
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
      // Consider adding logging here
      throw Exception("Error sending setting: $e");
    }
  }

  // Method to check if the device is connected
  Future<bool> isConnected() async {
    if (_connectedDevice == null) {
      return false;
    }
    var state = await _connectedDevice!.state.first;
    return state == BluetoothDeviceState.connected;
  }

  // Stream to monitor the connection state of the device
  Stream<BluetoothDeviceState>? get connectionStateStream {
    return _connectedDevice?.state;
  }
}
