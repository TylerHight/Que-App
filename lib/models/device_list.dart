import 'package:flutter/foundation.dart';
import 'device.dart';

class DeviceList extends ChangeNotifier {
  List<Device> _devices = [];

  List<Device> get devices => _devices;

  void add(Device device) {
    _devices.add(device);
    notifyListeners();
  }

  void remove(Device device) {
    _devices.remove(device);
    notifyListeners();
  }

  // Helper method to find a device by ID
  //Device? findById(String id) {
  //  // Use null-aware operators to handle null return from orElse
  //  return _devices.firstWhere((device) => device.id == id, orElse: () => null);
  //}

// Additional methods for functionality such as saving to storage, etc., can be added here
}
