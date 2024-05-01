import 'dart:math';

class Device {
  final String id;
  final String deviceName;
  final String connectedQueName;

  // Private constructor for generating a random ID
  Device._({
    required this.id,
    required this.deviceName,
    required this.connectedQueName,
  });

  // Factory constructor to generate a random ID if one is not provided
  factory Device({
    String? id,
    required String deviceName,
    required String connectedQueName,
  }) {
    // If no ID is provided, generate a random one
    final generatedId = id ?? _generateRandomId();
    return Device._(
      id: generatedId,
      deviceName: deviceName,
      connectedQueName: connectedQueName,
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
  }) =>
      Device(
        id: id ?? this.id,
        deviceName: deviceName ?? this.deviceName,
        connectedQueName: connectedQueName ?? this.connectedQueName,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceName': deviceName,
    'connectedQueueName': connectedQueName,
  };
}
