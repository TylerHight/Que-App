// lib/core/models/device/device_persistence.dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'device.dart';
import 'device_state.dart';

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

  static Device fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      deviceName: json['deviceName'],
      connectedQueName: json['connectedQueueName'],
      emission1Duration: Duration(seconds: json['emission1Duration']),
      emission2Duration: Duration(seconds: json['emission2Duration']),
      releaseInterval1: Duration(seconds: json['releaseInterval1']),
      releaseInterval2: Duration(seconds: json['releaseInterval2']),
      isBleConnected: json['isBleConnected'],
      isPeriodicEmissionEnabled: json['isPeriodicEmissionEnabled'],
      isPeriodicEmissionEnabled2: json['isPeriodicEmissionEnabled2'],
      heartrateThreshold: json['heartrateThreshold'],
      bluetoothServiceCharacteristics: Map<String, List<String>>.from(
        (json['bluetoothServiceCharacteristics'] as Map).map(
              (key, value) => MapEntry(
            key,
            (value as List).cast<String>(),
          ),
        ),
      ),
    );
  }
}