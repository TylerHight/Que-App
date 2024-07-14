// TODO: remove device settings from device.dart and put them here

class DeviceSettings {
  final String id;
  final String deviceId;
  final String settingName;
  final String settingValue;

  DeviceSettings({
    required this.id,
    required this.deviceId,
    required this.settingName,
    required this.settingValue,
  });

  DeviceSettings copy({
    String? id,
    String? deviceId,
    String? settingName,
    String? settingValue,
  }) =>
      DeviceSettings(
        id: id ?? this.id,
        deviceId: deviceId ?? this.deviceId,
        settingName: settingName ?? this.settingName,
        settingValue: settingValue ?? this.settingValue,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceId': deviceId,
    'settingName': settingName,
    'settingValue': settingValue,
  };
}
