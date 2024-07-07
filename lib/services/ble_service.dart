import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';
import '../models/device.dart';

class BleService {
  final String serviceUUID = "0000180a-0000-1000-8000-00805f9b34fb";
  final String controlCharacteristicUUID = "00002a57-0000-1000-8000-00805f9b34fb";
  final String settingCharacteristicUUID = "19b10001-e8f2-537e-4f6c-d104768a1214";

  BluetoothCharacteristic? controlCharacteristic;
  BluetoothCharacteristic? settingCharacteristic;
  BluetoothDevice? _connectedDevice;
  StreamSubscription<BluetoothDeviceState>? _connectionSubscription;

  // A stream controller to broadcast connection status updates
  final _connectionStatusController = StreamController<bool>.broadcast();

  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  BluetoothDevice? get connectedDevice => _connectedDevice;

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      print('Connecting to device: ${device.name}');
      await device.connect();
      _connectedDevice = device;
      await discoverServicesAndCharacteristics(device);

      // Listen to connection state changes
      _connectionSubscription = _connectedDevice!.state.listen((state) {
        bool isConnected = state == BluetoothDeviceState.connected;
        _connectionStatusController.add(isConnected);
      });

      // Emit initial connection status
      _connectionStatusController.add(true);
    } catch (e) {
      throw Exception("Error connecting to device: $e");
    }
  }

  Future<void> discoverServicesAndCharacteristics(BluetoothDevice device) async {
    print("Discovering services...");
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
  }

  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    try {
      print("Awaiting device disconnect");
      await device.disconnect();
      _connectedDevice = null;
      _connectionSubscription?.cancel();
      _connectionStatusController.add(false);

      // Add any cleanup logic that was previously in deleteDevice here
      print('Device disconnected and cleaned up');
    } catch (e) {
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

  Future<bool> isConnected() async {
    if (_connectedDevice == null) {
      return false;
    }
    var state = await _connectedDevice!.state.first;
    return state == BluetoothDeviceState.connected;
  }

  Stream<BluetoothDeviceState>? get connectionStateStream {
    return _connectedDevice?.state;
  }

  Future<bool> areAnyDevicesConnected() async {
    List<BluetoothDevice> connectedDevices = await FlutterBlue.instance.connectedDevices;
    return connectedDevices.isNotEmpty;
  }

  void dispose() {
    _connectionSubscription?.cancel();
    _connectionStatusController.close();
  }
}
