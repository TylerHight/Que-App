// lib/core/models/device/device.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Device extends Equatable {
  static const Duration defaultEmissionDuration = Duration(seconds: 10);
  static const Duration defaultReleaseInterval = Duration(minutes: 5);
  static const int defaultHeartRateThreshold = 90;

  final String id;
  final String deviceName;
  final String connectedQueName;
  final BluetoothDevice? bluetoothDevice;
  final Duration emission1Duration;
  final Duration emission2Duration;
  final Duration releaseInterval1;
  final Duration releaseInterval2;
  final bool isPeriodicEmissionEnabled;
  final bool isPeriodicEmissionEnabled2;
  final bool isBleConnected;
  final int heartrateThreshold;

  bool get isConnected => isBleConnected;

  const Device({
    required this.id,
    required this.deviceName,
    required this.connectedQueName,
    this.bluetoothDevice,
    required this.emission1Duration,
    required this.emission2Duration,
    required this.releaseInterval1,
    required this.releaseInterval2,
    required this.isPeriodicEmissionEnabled,
    required this.isPeriodicEmissionEnabled2,
    required this.isBleConnected,
    required this.heartrateThreshold,
  });

  // Factory constructor for creating a new device
  factory Device.create({
    required String name,
    BluetoothDevice? bluetoothDevice,
  }) {
    return Device(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      deviceName: name,
      connectedQueName: bluetoothDevice?.platformName ?? 'Unnamed Device',
      bluetoothDevice: bluetoothDevice,
      emission1Duration: defaultEmissionDuration,
      emission2Duration: defaultEmissionDuration,
      releaseInterval1: defaultReleaseInterval,
      releaseInterval2: defaultReleaseInterval,
      isPeriodicEmissionEnabled: false,
      isPeriodicEmissionEnabled2: false,
      isBleConnected: false,
      heartrateThreshold: defaultHeartRateThreshold,
    );
  }

  // Factory for creating an empty device
  factory Device.empty() {
    return const Device(
      id: '',
      deviceName: '',
      connectedQueName: '',
      emission1Duration: defaultEmissionDuration,
      emission2Duration: defaultEmissionDuration,
      releaseInterval1: defaultReleaseInterval,
      releaseInterval2: defaultReleaseInterval,
      isPeriodicEmissionEnabled: false,
      isPeriodicEmissionEnabled2: false,
      isBleConnected: false,
      heartrateThreshold: defaultHeartRateThreshold,
    );
  }

  Device copyWith({
    String? id,
    String? deviceName,
    String? connectedQueName,
    BluetoothDevice? bluetoothDevice,
    Duration? emission1Duration,
    Duration? emission2Duration,
    Duration? releaseInterval1,
    Duration? releaseInterval2,
    bool? isPeriodicEmissionEnabled,
    bool? isPeriodicEmissionEnabled2,
    bool? isBleConnected,
    int? heartrateThreshold,
  }) {
    return Device(
      id: id ?? this.id,
      deviceName: deviceName ?? this.deviceName,
      connectedQueName: connectedQueName ?? this.connectedQueName,
      bluetoothDevice: bluetoothDevice ?? this.bluetoothDevice,
      emission1Duration: emission1Duration ?? this.emission1Duration,
      emission2Duration: emission2Duration ?? this.emission2Duration,
      releaseInterval1: releaseInterval1 ?? this.releaseInterval1,
      releaseInterval2: releaseInterval2 ?? this.releaseInterval2,
      isPeriodicEmissionEnabled: isPeriodicEmissionEnabled ?? this.isPeriodicEmissionEnabled,
      isPeriodicEmissionEnabled2: isPeriodicEmissionEnabled2 ?? this.isPeriodicEmissionEnabled2,
      isBleConnected: isBleConnected ?? this.isBleConnected,
      heartrateThreshold: heartrateThreshold ?? this.heartrateThreshold,
    );
  }

  Device updateConnectionStatus(bool isConnected) {
    return copyWith(isBleConnected: isConnected);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceName': deviceName,
      'connectedQueName': connectedQueName,
      'emission1Duration': emission1Duration.inSeconds,
      'emission2Duration': emission2Duration.inSeconds,
      'releaseInterval1': releaseInterval1.inSeconds,
      'releaseInterval2': releaseInterval2.inSeconds,
      'isPeriodicEmissionEnabled': isPeriodicEmissionEnabled ? 1 : 0,
      'isPeriodicEmissionEnabled2': isPeriodicEmissionEnabled2 ? 1 : 0,
      'isBleConnected': isBleConnected ? 1 : 0,
      'heartrateThreshold': heartrateThreshold,
    };
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      deviceName: json['deviceName'] as String,
      connectedQueName: json['connectedQueName'] as String,
      emission1Duration: Duration(seconds: json['emission1Duration'] as int),
      emission2Duration: Duration(seconds: json['emission2Duration'] as int),
      releaseInterval1: Duration(seconds: json['releaseInterval1'] as int),
      releaseInterval2: Duration(seconds: json['releaseInterval2'] as int),
      isPeriodicEmissionEnabled: (json['isPeriodicEmissionEnabled'] as int) == 1,
      isPeriodicEmissionEnabled2: (json['isPeriodicEmissionEnabled2'] as int) == 1,
      isBleConnected: (json['isBleConnected'] as int) == 1,
      heartrateThreshold: json['heartrateThreshold'] as int,
    );
  }

  @override
  List<Object?> get props => [
    id,
    deviceName,
    connectedQueName,
    bluetoothDevice,
    emission1Duration,
    emission2Duration,
    releaseInterval1,
    releaseInterval2,
    isPeriodicEmissionEnabled,
    isPeriodicEmissionEnabled2,
    isBleConnected,
    heartrateThreshold,
  ];
}