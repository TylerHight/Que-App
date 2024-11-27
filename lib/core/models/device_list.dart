// lib/core/models/device_list.dart
import 'package:flutter/foundation.dart';
import 'device/index.dart';

class DeviceList extends ChangeNotifier {
  final Set<Device> _devices = {};

  List<Device> get devices => _devices.toList();

  bool hasDevice(String id) {
    return _devices.any((device) => device.id == id);
  }

  void add(Device device) {
    // Remove existing device with same ID if it exists
    _devices.removeWhere((d) => d.id == device.id);
    _devices.add(device);
    notifyListeners();
  }

  void remove(Device device) {
    _devices.remove(device);
    notifyListeners();
  }

  Future<void> removeDevice(Device device) async {
    await device.delete();
    remove(device);
  }

  Device? findDeviceById(String id) {
    try {
      return _devices.firstWhere((device) => device.id == id);
    } catch (_) {
      return null;
    }
  }
}