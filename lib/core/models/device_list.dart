// lib/core/models/device_list.dart

import 'package:flutter/foundation.dart';
import 'device/device.dart';

class DeviceList extends ChangeNotifier {
  final List<Device> _devices = [];

  List<Device> get devices => List.unmodifiable(_devices);

  void add(Device device) {
    _devices.add(device);
    notifyListeners();
  }

  void remove(Device device) {
    _devices.removeWhere((d) => d.id == device.id);
    notifyListeners();
  }

  void update(Device device) {
    final index = _devices.indexWhere((d) => d.id == device.id);
    if (index != -1) {
      _devices[index] = device;
      notifyListeners();
    }
  }

  Device? findById(String id) {
    try {
      return _devices.firstWhere((device) => device.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> removeDevice(Device device) async {
    _devices.removeWhere((d) => d.id == device.id);
    notifyListeners();
  }

  void clear() {
    _devices.clear();
    notifyListeners();
  }
}