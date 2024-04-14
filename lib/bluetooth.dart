import 'package:flutter_blue/flutter_blue.dart';

class Bluetooth {
  static final Bluetooth _instance = Bluetooth._internal();
  late FlutterBlue _flutterBlue;
  late BLEController _bleController;

  factory Bluetooth() {
    return _instance;
  }

  Bluetooth._internal() {
    _flutterBlue = FlutterBlue.instance;
    _bleController = BLEController();
  }

  // Method to connect to a BLE device
  Future<void> connectToDevice(BluetoothDevice device) async {
    await _bleController.connectToDevice(device);
  }

  // Method to disconnect from the connected BLE device
  Future<void> disconnectFromDevice() async {
    await _bleController.disconnect();
  }

  // Method to send data to the connected BLE device
  Future<void> sendData(List<int> data) async {
    await _bleController.sendData(data);
  }

  // Scan for available BLE devices
  Stream<List<ScanResult>> scanForDevices() {
    return _flutterBlue.scanResults;
  }
}

class BLEController {
  BluetoothDevice? _connectedDevice;
  late BluetoothCharacteristic _characteristic;

  // Method to connect to a BLE device
  Future<void> connectToDevice(BluetoothDevice device) async {
    _connectedDevice = device;
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          _characteristic = characteristic;
          return;
        }
      }
    }
    throw Exception('No writable characteristic found.');
  }

  // Method to disconnect from the connected BLE device
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
    }
  }

  // Method to send data to the connected BLE device
  Future<void> sendData(List<int> data) async {
    if (_characteristic != null) {
      await _characteristic.write(data);
    } else {
      throw Exception('No characteristic available to write data.');
    }
  }
}

