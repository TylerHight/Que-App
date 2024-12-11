// lib/core/services/ble/managers/characteristics_manager.dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../ble_types.dart';
import '../../../constants/ble_constants.dart';

class BleCharacteristicsManager {
  final ErrorCallback onError;
  final Map<String, BluetoothCharacteristic> _characteristics = {};

  BleCharacteristicsManager({required this.onError});

  Future<void> discoverCharacteristics(BluetoothDevice device) async {
    try {
      _characteristics.clear();
      final services = await device.discoverServices();

      print('\n=== BLE Service Discovery Debug ===');
      print('Total services discovered: ${services.length}');

      for (final service in services) {
        print('\nService UUID: ${service.uuid}');
        print('Characteristics in this service: ${service.characteristics.length}');

        for (final char in service.characteristics) {
          print('  Characteristic UUID: ${char.uuid}');
          print('  Properties: ${_getCharacteristicProperties(char)}');
          _characteristics[char.uuid.toString().toLowerCase()] = char;
        }
      }

      print('\nSearching for LED service: ${BleConstants.LED_SERVICE_UUID}');
      final ledService = services.firstWhere(
            (s) => s.uuid.toString().toLowerCase() == BleConstants.LED_SERVICE_UUID.toLowerCase(),
        orElse: () => throw BleException('LED service not found'),
      );

      print('Found LED service. Checking for switch characteristic...');
      final switchChar = ledService.characteristics.firstWhere(
            (c) => c.uuid.toString().toLowerCase() == BleConstants.SWITCH_CHARACTERISTIC_UUID.toLowerCase(),
        orElse: () => throw BleException('Switch characteristic not found'),
      );

      _characteristics[BleConstants.SWITCH_CHARACTERISTIC_UUID.toLowerCase()] = switchChar;
      print('Successfully found and stored switch characteristic');

    } catch (e) {
      print('Error during service discovery: $e');
      onError('Failed to discover characteristics: $e');
      rethrow;
    }
  }

  String _getCharacteristicProperties(BluetoothCharacteristic char) {
    List<String> props = [];
    if (char.properties.read) props.add('Read');
    if (char.properties.write) props.add('Write');
    if (char.properties.notify) props.add('Notify');
    if (char.properties.indicate) props.add('Indicate');
    if (char.properties.authenticatedSignedWrites) props.add('AuthSignedWrites');
    if (char.properties.broadcast) props.add('Broadcast');
    if (char.properties.writeWithoutResponse) props.add('WriteNoResponse');
    return props.join(', ');
  }

  Future<List<int>> readCharacteristic(String uuid) async {
    try {
      final char = _getCharacteristic(uuid);
      return await char.read();
    } catch (e) {
      onError('Failed to read characteristic $uuid: $e');
      rethrow;
    }
  }

  Future<void> writeCharacteristic(String uuid, List<int> data) async {
    try {
      final char = _getCharacteristic(uuid);
      print('Writing to characteristic $uuid: $data');
      await char.write(data, withoutResponse: false);
    } catch (e) {
      onError('Failed to write to characteristic $uuid: $e');
      rethrow;
    }
  }

  BluetoothCharacteristic _getCharacteristic(String uuid) {
    final normalizedUuid = uuid.toLowerCase();
    final char = _characteristics[normalizedUuid];

    if (char == null) {
      final availableCharacteristics = _characteristics.keys.join(', ');
      throw BleException('''
Characteristic not found: $uuid
Available characteristics: $availableCharacteristics
''');
    }

    return char;
  }

  void dispose() {
    _characteristics.clear();
  }
}