/// device.dart
class Device {
  final String deviceName;
  final String connectedQueueName;

  Device({
    required this.deviceName,
    required this.connectedQueueName,
  });

  Device copy({
    String? deviceName,
    String? connectedQueueName,
  }) =>
      Device(
        deviceName: deviceName ?? this.deviceName,
        connectedQueueName: connectedQueueName ?? this.connectedQueueName,
      );

  Map<String, dynamic> toJson() => {
    'deviceName': deviceName,
    'connectedQueueName': connectedQueueName,
  };
}
