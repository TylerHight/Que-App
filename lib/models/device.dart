class Device {
  final String id;
  final String name;
  final String type;
  bool isConnected;

  Device({required this.id, required this.name, required this.type, this.isConnected = false});
}

class DeviceSettings {
  final String id;
  final Device device;
  final String settingName;
  var settingValue;

  DeviceSettings({required this.id, required this.device, required this.settingName, this.settingValue});
}