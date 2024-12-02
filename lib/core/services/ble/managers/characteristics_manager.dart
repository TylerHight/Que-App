// lib/core/services/ble/managers/characteristics_manager.dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../ble_types.dart';
import '../../../constants/ble_constants.dart';

class BleCharacteristicsManager {
  final ErrorCallback onError;
  final Map<String, BluetoothCharacteristic> _characteristics = {};

  BleCharacteristicsManager({required this.onError});

  Future<void> discoverCharacteristics(BluetoothDevice device) async {
    final services = await device.discoverServices();

    for (final service in services) {
      if (service.uuid.toString().toLowerCase() == BleConstants.LED_SERVICE_UUID.toLowerCase()) {
        for (final char in service.characteristics) {
          _characteristics[char.uuid.toString().toLowerCase()] = char;
        }
      }
    }
  }

  Future<List<int>> readCharacteristic(String uuid) async {
    final char = _getCharacteristic(uuid);
    return await char.read();
  }

  Future<void> writeCharacteristic(String uuid, List<int> data) async {
    final char = _getCharacteristic(uuid);
    await char.write(data);
  }

  BluetoothCharacteristic _getCharacteristic(String uuid) {
    final char = _characteristics[uuid.toLowerCase()];
    if (char == null) {
      throw BleException('Characteristic not found: $uuid');
    }
    return char;
  }

  void dispose() {
    _characteristics.clear();
  }
}