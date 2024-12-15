// lib/features/device_control/handlers/device_creation_handler.dart

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../core/models/device/device.dart';

class DeviceCreationHandler {
  static Device createNewDevice({
    required String name,
    BluetoothDevice? bluetoothDevice,
  }) {
    return Device(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      deviceName: name,
      // Provide a default value for connectedQueName if no bluetooth device
      connectedQueName: bluetoothDevice?.platformName ?? 'Unnamed Device',
      bluetoothDevice: bluetoothDevice,
      emission1Duration: Device.defaultEmissionDuration,
      emission2Duration: Device.defaultEmissionDuration,
      releaseInterval1: Device.defaultReleaseInterval,
      releaseInterval2: Device.defaultReleaseInterval,
      isPeriodicEmissionEnabled: false,
      isPeriodicEmissionEnabled2: false,
      isBleConnected: false,
      heartrateThreshold: Device.defaultHeartRateThreshold,
    );
  }

  static Map<String, dynamic> toMap(Device device) {
    return {
      'id': device.id,
      'deviceName': device.deviceName,
      'connectedQueName': device.connectedQueName,
      'emission1Duration': device.emission1Duration.inSeconds,
      'emission2Duration': device.emission2Duration.inSeconds,
      'releaseInterval1': device.releaseInterval1.inSeconds,
      'releaseInterval2': device.releaseInterval2.inSeconds,
      'isBleConnected': device.isBleConnected ? 1 : 0,
      'isPeriodicEmissionEnabled': device.isPeriodicEmissionEnabled ? 1 : 0,
      'isPeriodicEmissionEnabled2': device.isPeriodicEmissionEnabled2 ? 1 : 0,
      'heartrateThreshold': device.heartrateThreshold,
      'bluetoothServiceCharacteristics': device.bluetoothDevice?.toString() ?? '',
    };
  }

  static Future<void> validateAndCreateDevice({
    required String name,
    required BluetoothDevice? bluetoothDevice,
    required Function(Device) onDeviceCreated,
    required Function(String) onError,
  }) async {
    try {
      // Validate name
      if (name.trim().isEmpty) {
        throw Exception('Device name cannot be empty');
      }

      // Create device
      final device = createNewDevice(
        name: name,
        bluetoothDevice: bluetoothDevice,
      );

      // Call success callback
      onDeviceCreated(device);
    } catch (e) {
      onError(e.toString());
    }
  }
}