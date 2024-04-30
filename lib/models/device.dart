/// device.dart
class Device {
  final String id;
  final String deviceName;
  final String connectedQueueName;

  Device({
    required this.id,
    required this.deviceName,
    required this.connectedQueueName,
  });

  Device copy({
    String? id,
    String? deviceName,
    String? connectedQueueName,
  }) =>
      Device(
        id: id ?? this.id,
        deviceName: deviceName ?? this.deviceName,
        connectedQueueName: connectedQueueName ?? this.connectedQueueName,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceName': deviceName,
    'connectedQueueName': connectedQueueName,
  };
}
