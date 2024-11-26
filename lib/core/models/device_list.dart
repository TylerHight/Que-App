import 'package:flutter/foundation.dart';
import 'device/index.dart';

class DeviceList extends ChangeNotifier {
  final List<Device> _devices = [];

  List<Device> get devices => _devices;

  void add(Device device) {
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

// Additional methods for functionality such as saving to storage, etc., can be added here
}
