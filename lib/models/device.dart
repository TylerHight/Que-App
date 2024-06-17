import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';

class Device extends ChangeNotifier {
  final String id;
  final String deviceName;
  final String connectedQueName;
  static const Duration defaultEmissionDuration = const Duration(seconds: 10);
  Duration _emission1Duration;
  Duration _emission2Duration;
  Duration _releaseInterval1;  // New variable
  Duration _releaseInterval2;  // New variable
  bool _isPeriodicEmissionEnabled; // Changed to private
  bool _isPeriodicEmissionEnabled2; // Changed to private
  bool isBleConnected;

  final String serviceUUID = "0000180a-0000-1000-8000-00805f9b34fb";
  final String controlCharacteristicUUID = "00002a57-0000-1000-8000-00805f9b34fb";
  final String settingCharacteristicUUID = "19b10001-e8f2-537e-4f6c-d104768a1214";

  BluetoothCharacteristic? controlCharacteristic;
  BluetoothCharacteristic? settingCharacteristic;

  final Map<String, List<String>> bluetoothServiceCharacteristics;

  Duration get emission1Duration => _emission1Duration;
  set emission1Duration(Duration value) {
    _emission1Duration = value;
    notifyListeners();
  }

  Duration get emission2Duration => _emission2Duration;
  set emission2Duration(Duration value) {
    _emission2Duration = value;
    notifyListeners();
  }

  Duration get releaseInterval1 => _releaseInterval1; // New getter
  set releaseInterval1(Duration value) {
    _releaseInterval1 = value;
    notifyListeners();
  }

  Duration get releaseInterval2 => _releaseInterval2; // New getter
  set releaseInterval2(Duration value) {
    _releaseInterval2 = value;
    notifyListeners();
  }

  bool get isPeriodicEmissionEnabled => _isPeriodicEmissionEnabled;
  set isPeriodicEmissionEnabled(bool value) {
    _isPeriodicEmissionEnabled = value;
    notifyListeners();
  }

  bool get isPeriodicEmissionEnabled2 => _isPeriodicEmissionEnabled2;
  set isPeriodicEmissionEnabled2(bool value) {
    _isPeriodicEmissionEnabled2 = value;
    notifyListeners();
  }

  Device._({
    required this.id,
    required this.deviceName,
    required this.connectedQueName,
    required Duration emission1Duration,
    required Duration emission2Duration,
    required Duration releaseInterval1,  // New parameter
    required Duration releaseInterval2,  // New parameter
    required bool isPeriodicEmissionEnabled,
    required bool isPeriodicEmissionEnabled2,
    required this.isBleConnected,
    required this.bluetoothServiceCharacteristics,
  })  : _emission1Duration = emission1Duration,
        _emission2Duration = emission2Duration,
        _releaseInterval1 = releaseInterval1,  // Initialize new variable
        _releaseInterval2 = releaseInterval2,  // Initialize new variable
        _isPeriodicEmissionEnabled = isPeriodicEmissionEnabled,
        _isPeriodicEmissionEnabled2 = isPeriodicEmissionEnabled2,
        super();

  factory Device({
    String? id,
    required String deviceName,
    required String connectedQueName,
    Duration? emission1Duration,
    Duration? emission2Duration,
    Duration? releaseInterval1,  // New parameter
    Duration? releaseInterval2,  // New parameter
    bool? isBleConnected,
    bool? isPeriodicEmissionEnabled = false,
    bool? isPeriodicEmissionEnabled2 = false,
    Map<String, List<String>>? bluetoothServiceCharacteristics,
  }) {
    final generatedId = id ?? _generateRandomId();
    return Device._(
      id: generatedId,
      deviceName: deviceName,
      connectedQueName: connectedQueName,
      emission1Duration: emission1Duration ?? defaultEmissionDuration,
      emission2Duration: emission2Duration ?? defaultEmissionDuration,
      releaseInterval1: releaseInterval1 ?? Duration(seconds: 5),  // Default value
      releaseInterval2: releaseInterval2 ?? Duration(seconds: 5),  // Default value
      isBleConnected: isBleConnected ?? false,
      isPeriodicEmissionEnabled: isPeriodicEmissionEnabled ?? false,
      isPeriodicEmissionEnabled2: isPeriodicEmissionEnabled2 ?? false,
      bluetoothServiceCharacteristics: bluetoothServiceCharacteristics ?? {},
    );
  }

  static String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final idLength = 10;
    return String.fromCharCodes(
      Iterable.generate(
        idLength,
            (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  String? getCharacteristicUUID(String serviceUUID) {
    final characteristics = bluetoothServiceCharacteristics[serviceUUID];
    if (characteristics != null) {
      if (characteristics.isNotEmpty) {
        return characteristics.first;
      } else {
        print("No characteristic UUIDs found for service UUID: $serviceUUID");
        return null;
      }
    } else {
      print("Service UUID not found: $serviceUUID");
      return null;
    }
  }

  Device copy({
    String? id,
    String? deviceName,
    String? connectedQueName,
    Duration? emission1Duration,
    Duration? emission2Duration,
    Duration? releaseInterval1,  // New parameter
    Duration? releaseInterval2,  // New parameter
    bool? isBleConnected,
    bool? isPeriodicEmissionEnabled,
    bool? isPeriodicEmissionEnabled2,
    Map<String, List<String>>? bluetoothServiceCharacteristics,
  }) =>
      Device(
        id: id ?? this.id,
        deviceName: deviceName ?? this.deviceName,
        connectedQueName: connectedQueName ?? this.connectedQueName,
        emission1Duration: emission1Duration ?? this.emission1Duration,
        emission2Duration: emission2Duration ?? this.emission2Duration,
        releaseInterval1: releaseInterval1 ?? this.releaseInterval1,  // Copy new variable
        releaseInterval2: releaseInterval2 ?? this.releaseInterval2,  // Copy new variable
        isBleConnected: isBleConnected ?? this.isBleConnected,
        isPeriodicEmissionEnabled: isPeriodicEmissionEnabled ?? this.isPeriodicEmissionEnabled,
        isPeriodicEmissionEnabled2: isPeriodicEmissionEnabled2 ?? this.isPeriodicEmissionEnabled2,
        bluetoothServiceCharacteristics: bluetoothServiceCharacteristics ?? this.bluetoothServiceCharacteristics,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceName': deviceName,
    'connectedQueueName': connectedQueName,
    'emission1Duration': emission1Duration.inSeconds,
    'emission2Duration': emission2Duration.inSeconds,
    'releaseInterval1': releaseInterval1.inSeconds,  // Include new variable
    'releaseInterval2': releaseInterval2.inSeconds,  // Include new variable
    'isBleConnected': isBleConnected,
    'isPeriodicEmissionEnabled': isPeriodicEmissionEnabled,
    'isPeriodicEmissionEnabled2': isPeriodicEmissionEnabled2,
    'bluetoothServiceCharacteristics': bluetoothServiceCharacteristics,
  };
}
