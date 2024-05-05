/// device.dart

import 'dart:math';

class Device {
  final String id;
  final String deviceName;
  final String connectedQueName;
  final Duration emission1Duration;
  final Duration emission2Duration;

  // Private constructor for generating a random ID
  Device._({
    required this.id,
    required this.deviceName,
    required this.connectedQueName,
    this.emission1Duration = const Duration(seconds: 40),
    this.emission2Duration = const Duration(seconds: 40),
  });

  // Factory constructor to generate a random ID if one is not provided
  factory Device({
    String? id,
    required String deviceName,
    required String connectedQueName,
    Duration? emission1Duration,
    Duration? emission2Duration,
  }) {
    // If no ID is provided, generate a random one
    final generatedId = id ?? _generateRandomId();
    return Device._(
      id: generatedId,
      deviceName: deviceName,
      connectedQueName: connectedQueName,
      emission1Duration: emission1Duration ?? const Duration(seconds: 40),
      emission2Duration: emission2Duration ?? const Duration(seconds: 40),
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
  }) =>
      Device(
        id: id ?? this.id,
        deviceName: deviceName ?? this.deviceName,
        connectedQueName: connectedQueName ?? this.connectedQueName,
        emission1Duration: emission1Duration ?? this.emission1Duration,
        emission2Duration: emission2Duration ?? this.emission2Duration,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceName': deviceName,
    'connectedQueueName': connectedQueName,
    'emission1Duration': emission1Duration.inSeconds,
    'emission2Duration': emission2Duration.inSeconds,
  };
}
