import 'package:flutter_blue/flutter_blue.dart';
import 'package:que_app/device_data.dart';

class Bluetooth {
  static final Bluetooth _instance = Bluetooth._internal();
  late FlutterBlue _flutterBlue;
  late BLEController _bleController;
  List<BluetoothDevice> _availableDevices = []; // Define _availableDevices list

  factory Bluetooth() {
    return _instance;
  }

  Bluetooth._internal() {
    _flutterBlue = FlutterBlue.instance;
    _bleController = BLEController();
  }

  BLEController get bleController => _bleController;

  Future<void> connectToDevice(BluetoothDevice device) async {
    await _bleController.connectToDevice(device);

    String deviceTitle = "Arduino Nano BLE 33";
    String bluetoothDeviceID = device.id.toString();

    DeviceData().addDeviceTitle(deviceTitle, bluetoothDeviceID: bluetoothDeviceID);
  }

  Future<void> disconnectFromDevice() async {
    await _bleController.disconnect();
  }

  Future<void> sendData(List<int> data) async {
    await _bleController.sendData(data);
  }

  Stream<List<ScanResult>> scanForDevices() {
    return _flutterBlue.scanResults;
  }

  // Method to handle scanning for devices and populating _availableDevices list
  void startDeviceScanning() {
    scanForDevices().listen((List<ScanResult> results) {
      _availableDevices.clear(); // Clear the list before populating with new results
      for (ScanResult result in results) {
        if (!_availableDevices.contains(result.device)) {
          _availableDevices.add(result.device);
        }
      }
      // Optionally, you can notify listeners or update UI with the new list of available devices
    });
  }

  List<BluetoothDevice> get availableDevices => _availableDevices;
}


class BLEController {
  BluetoothDevice? _connectedDevice;
  late BluetoothCharacteristic _characteristic;

  // Getter to access the connected Bluetooth device
  BluetoothDevice? get connectedDevice => _connectedDevice;

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


