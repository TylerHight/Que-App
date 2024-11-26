// lib/core/models/device/device_persistence.dart
import 'device.dart';

extension DevicePersistence on Device {
  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceName': deviceName,
    'connectedQueueName': connectedQueName,
    'emission1Duration': emission1Duration.inSeconds,
    'emission2Duration': emission2Duration.inSeconds,
    'releaseInterval1': releaseInterval1.inSeconds,
    'releaseInterval2': releaseInterval2.inSeconds,
    'isBleConnected': isBleConnected,
    'isPeriodicEmissionEnabled': isPeriodicEmissionEnabled,
    'isPeriodicEmissionEnabled2': isPeriodicEmissionEnabled2,
    'heartrateThreshold': heartrateThreshold,
    'bluetoothServiceCharacteristics': bluetoothServiceCharacteristics,
  };
}