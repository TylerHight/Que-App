import 'dart:math';

class Device {
  final String id;
  final String deviceName;
  final String connectedQueName;
  static const Duration defaultEmissionDuration = const Duration(seconds: 40);
  final Duration emission1Duration;
  final Duration emission2Duration;

  // Map to associate characteristics with their respective services
  final Map<String, List<String>> bluetoothServiceCharacteristics;

  // Private constructor for generating a random ID
  Device._({
    required this.id,
    required this.deviceName,
    required this.connectedQueName,
    this.emission1Duration = defaultEmissionDuration,
    this.emission2Duration = defaultEmissionDuration,
    required this.bluetoothServiceCharacteristics,
  });

  // Factory constructor to generate a random ID if one is not provided
  factory Device({
    String? id,
    required String deviceName,
    required String connectedQueName,
    Duration? emission1Duration,
    Duration? emission2Duration,
    required Map<String, List<String>> bluetoothServiceCharacteristics,
  }) {
    // If no ID is provided, generate a random one
    final generatedId = id ?? _generateRandomId();
    return Device._(
      id: generatedId,
      deviceName: deviceName,
      connectedQueName: connectedQueName,
      emission1Duration: emission1Duration ?? defaultEmissionDuration,
      emission2Duration: emission2Duration ?? defaultEmissionDuration,
      bluetoothServiceCharacteristics: bluetoothServiceCharacteristics,
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

  Device copy({
    String? id,
    String? deviceName,
    String? connectedQueName,
    Duration? emission1Duration,
    Duration? emission2Duration,
    Map<String, List<String>>? bluetoothServiceCharacteristics,
  }) =>
      Device(
        id: id ?? this.id,
        deviceName: deviceName ?? this.deviceName,
        connectedQueName: connectedQueName ?? this.connectedQueName,
        emission1Duration: emission1Duration ?? this.emission1Duration,
        emission2Duration: emission2Duration ?? this.emission2Duration,
        bluetoothServiceCharacteristics: bluetoothServiceCharacteristics ?? this.bluetoothServiceCharacteristics,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceName': deviceName,
    'connectedQueueName': connectedQueName,
    'emission1Duration': emission1Duration.inSeconds,
    'emission2Duration': emission2Duration.inSeconds,
    'bluetoothServiceCharacteristics': bluetoothServiceCharacteristics,
  };
}
