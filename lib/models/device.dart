/// device.dart
class Device {
  final String id;
  final String name;
  final String type;
  bool isConnected;

  Device({required this.id, required this.name, required this.type, this.isConnected = false});

  Device copy({
    String? id,
    String? name,
    String? type,
    bool? isConnected,
  }) =>
      Device(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        isConnected: isConnected ?? this.isConnected,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'isConnected': isConnected,
  };
}

class DeviceSettings {
  final String id;
  final Device device;
  final String settingName;
  var settingValue;

  DeviceSettings({required this.id, required this.device, required this.settingName, this.settingValue});

  DeviceSettings copy({
    String? id,
    Device? device,
    String? settingName,
    dynamic settingValue,
  }) =>
      DeviceSettings(
        id: id ?? this.id,
        device: device ?? this.device,
        settingName: settingName ?? this.settingName,
        settingValue: settingValue ?? this.settingValue,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'device': device.toJson(),
    'settingName': settingName,
    'settingValue': settingValue,
  };
}
