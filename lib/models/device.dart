/// device.dart
class Device {
  final String id;
  final String deviceName;
  final String connectedQueName;

  Device({
    required this.id,
    required this.deviceName,
    required this.connectedQueName,
  });

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
