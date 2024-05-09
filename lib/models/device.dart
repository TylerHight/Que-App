import 'dart:math'; // For generating random IDs
import 'package:flutter_blue/flutter_blue.dart'; // For Bluetooth functionality

class Device {
  final String id;
  final String deviceName;
  final String connectedQueName;
  static const Duration defaultEmissionDuration = const Duration(seconds: 40);
  final Duration emission1Duration;
  final Duration emission2Duration;
  bool isBleConnected; // New variable for BLE connection status

  final String serviceUUID = "0000180a-0000-1000-8000-00805f9b34fb";
  final String controlCharacteristicUUID = "00002a57-0000-1000-8000-00805f9b34fb";
  final String settingCharacteristicUUID = "19b10001-e8f2-537e-4f6c-d104768a1214";

  BluetoothCharacteristic? controlCharacteristic;
  BluetoothCharacteristic? settingCharacteristic;

  // Map to associate characteristics with their respective services
  final Map<String, List<String>> bluetoothServiceCharacteristics;

  // Private constructor for generating a random ID
  Device._({
    required this.id,
    required this.deviceName,
    required this.connectedQueName,
    this.emission1Duration = defaultEmissionDuration,
    this.emission2Duration = defaultEmissionDuration,
    required this.isBleConnected, // Updated constructor
    required this.bluetoothServiceCharacteristics,
  });

  // Factory constructor to generate a random ID if one is not provided
  factory Device({
    String? id,
    required String deviceName,
    required String connectedQueName,
    Duration? emission1Duration,
    Duration? emission2Duration,
    bool? isBleConnected, // Updated constructor
    Map<String, List<String>>? bluetoothServiceCharacteristics, // Make it optional
  }) {
    // If no ID is provided, generate a random one
    final generatedId = id ?? _generateRandomId();
    return Device._(
      id: generatedId,
      deviceName: deviceName,
      connectedQueName: connectedQueName,
      emission1Duration: emission1Duration ?? defaultEmissionDuration,
      emission2Duration: emission2Duration ?? defaultEmissionDuration,
      isBleConnected: isBleConnected ?? false, // Assign default value
      bluetoothServiceCharacteristics: bluetoothServiceCharacteristics ?? {}, // Assign empty map as default
    );
  }

  // Method to generate a random ID
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

  // Method to get a specific characteristic UUID by service UUID
  String? getCharacteristicUUID(String serviceUUID) {
    final characteristics = bluetoothServiceCharacteristics[serviceUUID];
    if (characteristics != null) {
      if (characteristics.isNotEmpty) {
        // Return the first characteristic UUID associated with the service UUID
        return characteristics.first;
      } else {
        // If characteristics list is empty
        print("No characteristic UUIDs found for service UUID: $serviceUUID");
        return null;
      }
    } else {
      // If service UUID is not found
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
    bool? isBleConnected,
    Map<String, List<String>>? bluetoothServiceCharacteristics,
  }) =>
      Device(
        id: id ?? this.id,
        deviceName: deviceName ?? this.deviceName,
        connectedQueName: connectedQueName ?? this.connectedQueName,
        emission1Duration: emission1Duration ?? this.emission1Duration,
        emission2Duration: emission2Duration ?? this.emission2Duration,
        isBleConnected: isBleConnected ?? this.isBleConnected,
        bluetoothServiceCharacteristics: bluetoothServiceCharacteristics ?? this.bluetoothServiceCharacteristics,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceName': deviceName,
    'connectedQueueName': connectedQueName,
    'emission1Duration': emission1Duration.inSeconds,
    'emission2Duration': emission2Duration.inSeconds,
    'isBleConnected': isBleConnected, // Include isBleConnected in JSON serialization
    'bluetoothServiceCharacteristics': bluetoothServiceCharacteristics,
  };
}
